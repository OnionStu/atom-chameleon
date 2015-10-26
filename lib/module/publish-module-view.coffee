desc = require '../utils/text-description'
Util = require '../utils/util'
{$,TextEditorView,View} = require 'atom-space-pen-views'
{File,Directory} = require 'atom'
PathM = require 'path'
UtilExtend = require './../utils/util-extend'
ChameleonBox = require '../utils/chameleon-box-view'
fs = require 'fs-extra'
client = require '../utils/client'
loadingMask = require '../utils/loadingMask'

class PublishModuleInfoView extends View
  moduleConfigFileName: desc.moduleConfigFileName
  projectConfigFileName: desc.ProjectConfigFileName
  moduleLogoFileName: desc.moduleLogoFileName
  moduleLocatFileName: desc.moduleLocatFileName
  moduleIdentifer:null#模块标识
  moduleVersion:null#模块版本
  moduleConfPath:null
  moduleId:null
  currentPage:1
  firstPage:1
  lastPage:5
  countPage:0
  step:1
  pageShowItemNumber:4
  # 1 表示步骤 1。选择模块
  # 2 表示步骤 2.填写信息
  @content:() ->
    @div class : "upload-module", =>
      @div outlet: 'selectAppPathView', class:'form-horizontal form_width',=>
        @label desc.publishModuleFirstStep, class: 'label-width control-label'
        @div class: 'input-width', =>
          @select class: '', outlet: 'selectProject'
      @div outlet: 'fillMessageView',class:'form-horizontal form_width',=>
        @label desc.publishModuleSecondStep, class: 'label-width control-label'
        @div class: 'messageContain', =>
          @div class:"div-align-text", =>
            @img outlet:"logo",class:'pic', src: desc.getImgPath 'icon.png'
            @button desc.changeLogoBtn, outlet:"selectLogo",class:"btn btn-width"
          @div =>
            @div class:"div-display",=>
              @label desc.moduleNameLabel
              @div class:"div-inputText", =>
                @subview 'moduleName', new TextEditorView(mini: true)
            @div class:"div-display",=>
              @label desc.moduleUploadVersionLabel
              @div class:"div-inputText", =>
                @subview 'moduleUploadVersion', new TextEditorView(mini: true)
            @div class:"div-display",=>
              @label "更新内容:"
              @div class:"div-inputText", =>
                @subview 'moduleUploadLog', new TextEditorView(mini: true)
      @div outlet: 'uploadProgressView',class: 'form-horizontal form_width',=>
        @div class: "process-label", =>
          @span desc.moduleUploadProcessLabel ,outlet: "buildTips"
        @div class: "text-center", =>
          @progress class: 'inline-block'
      @div outlet: "moduleApplyView",class: 'form-horizontal form_width',=>
        @div class:"text-center", =>
          @span outlet:"getAppListTipsView","模块上传成功过，检测到以下应用已关联本模块，是否应用为模块的最新版本？"
          @br
        @div outlet:"tableView", =>
          @div outlet: "appListtable",=>
            @table class:"text-center", =>
              @thead =>
                @tr =>
                  @th "应用"
                  @th "平台"
                  @th "版本"
                  @th "是否应用"
              @tbody outlet:"appListMessage"
          @div class:"listOfPageView",=>
            @div outlet:"",=>
              @a "上一页",outlet:"prePage",click: "prePageClick"
              @div outlet:"pageIndex",class:"page-list"
              @a "下一页",outlet:"nextPage",click: "nextPageClick"
            @div =>
              @label outlet:"pageTipsView","共70个应用，第1页"

  open :(e) ->
    atom.pickFolder (paths) =>
      if paths?
        console.log paths[0]
        path = PathM.join paths[0]
        console.log  path
        @appPath.setText path
        # @show_path.html(path)
  # 上一步
  prevStep: ->
    if @step is 2
      @fillMessageView.hide()
      @selectAppPathView.show()
      @parentView.nextBtn.text("下一步")
      @step = 1
  # 下一步
  nextStep: ->
    if @step is 1
      @selectAppPathView.hide()
      @fillMessageView.show()
      @parentView.prevBtn.removeClass('hide')
      @parentView.nextBtn.text("上传")
      @step = 2
      @initFileMessageView()
    else if @step is 2
      console.log @moduleName.getText(),@moduleUploadVersion.getText()
      #判断模块名字和版本是否为空
      if @moduleName.getText().trim() == ""
        alert desc.moduleNameIsNullError
      else if @moduleUploadVersion.getText().trim() == ""
        alert desc.moduleVersionIsNullError
      else
        # 判断模块版本格式是否合法
        if @checkVersionIsLegal(@moduleUploadVersion.getText())
          @uploadModule()
        else
          alert desc.moduleVersionUnLegelError
          return

  #初始化表单
  initFileMessageView: ->
    console.log "selected file path ",@selectProject.val()
    @moduleConfPath = @selectProject.val()
    moduleMessage = Util.readJsonSync @moduleConfPath
    logoPath = PathM.join @moduleConfPath,"..",@moduleLogoFileName
    if moduleMessage
      @moduleIdentifer = moduleMessage['identifier']
      @moduleName.setText(moduleMessage['name'])
      @moduleUploadVersion.setText(moduleMessage['version'])
      if fs.existsSync(logoPath)
        @logo.attr("src",logoPath)

  # 判断版本是否合法，判断规则：是否由三个数和两个点组成
  checkVersionIsLegal:(version)->
    numbers = version.split('.')
    if numbers.length != 3
      return false
    if isNaN(numbers[0]) or isNaN(numbers[1]) or isNaN(numbers[2])
      return false
    return true
  # 上传模块包
  callUploadModuleApi:(filePath)->
    if fs.existsSync filePath
      params =
        formData: {
          up_file: fs.createReadStream(filePath)
        }
        sendCookie: true
        success: (data) =>
          console.log "上传模块成功"
          @moduleId=data["module_id"]
          @initAppListView()
        error: (msg) =>
          console.log msg
      client.uploadModuleZip(params)
    else
      alert "文件#{filePath}不存在"

  #初始化应用列表界面
  initAppListView:->
    @uploadProgressView.hide()
    @moduleApplyView.show()
    @callGetAppListApi(1)
    #根据 模块标识获取 与他相关联的应用标识
    #获取成功则显示

  #应用列表中  点击下一页
  nextPageClick:(m1,b1) ->
    #根据 模块标识获取 与他相关联的应用标识
    if @currentPage >= @countPage
      return
    console.log @currentPage+1
    @callGetAppListApi(@currentPage+1)

  #应用列表中点击上一页
  prePageClick:(m1,b1) ->
    #根据 模块标识获取 与他相关联的应用标识
    if @currentPage <= 1
      return
    @callGetAppListApi(@currentPage-1)

  #获取应用列表的第 page 页
  callGetAppListApi:(page) ->
    #page   页数
    # @moduleIdentifer = "yuzhe001"
    params =
      sendCookie: true
      success: (data) =>
        console.log data
        if data.hasOwnProperty("message")
          console.log data["message"]
          alert data["message"]
        else
          itemStr = []
          # 打印 table 的子节点
          printTableView = (item) =>
            if item["platform"] is "ANDROID"
              item["platform"] = "Android"
            else
              item["platform"] = "iOS"
            str = "<tr>
            <td>#{item["appName"]}</td>
            <td>#{item["platform"]}</td>
            <td>#{item["version"]}</td>
            <td><button class='btn appBtn' value='#{item["appVersionId"]}'>应用</button></td>
            </tr>"
            itemStr.push(str)
          printTableView item for item in data["AppAndVersions"]
          @appListMessage.html(itemStr.join(""))
          @countPage = data["paginationMap"]["totalPage"]
          @currentPage = page
          @firstPage = @currentPage
          if @countPage - @firstPage > 5
            @lastPage = @firstPage + 5
          else
            @lastPage = @countPage
            if @lastPage - 5 >0
              @firstPage = @lastPage - 5
            else
              @firstPage = 1
            # body...
          tmp = @firstPage
          aItemStr = []
          #初始化 a 标签
          printPageView = =>
            str = "<a>#{tmp}</a>"
            aItemStr.push(str)
            tmp = tmp + 1
          printPageView() while tmp <= @lastPage
          @pageIndex.html(aItemStr.join(""))
          @pageTipsView.html("共#{data["paginationMap"]["totalCount"]}个应用，第#{page}页")
          @.find(".appBtn").on "click",(e) => @appBtnClick(e)
      error: (msg) =>
        console.log msg
    client.getAppMessage params,@moduleIdentifer,page,@pageShowItemNumber

  appBtnClick:(e) ->
    el = e.currentTarget
    appVersionId = el.value
    console.log appVersionId
    moduleId = ""
    if appVersionId
      @callActInAppApi(appVersionId,el)

  #请求应用到应用
  callActInAppApi:(appVersionId,el)->
    #@moduleIdentifer  模块标识
    #@appVersionId     所要应用到的应用ID
    # @moduleId = "5629a80e0cf26371e4d32066"
    params =
      sendCookie: true
      success:(data) =>
        $(el).attr("disabled",true)
        console.log data
        alert data["message"]
      error: (msg) =>
        console.log msg
    client.applyModuleToApp(params,appVersionId,@moduleId)


  # 0、检测版本；1、压缩文件；2、上传压缩包；3删除压缩包
  uploadModule: ->
    console.log "begin to upload ",@selectProject.val()
    moduleIdentiferList = []
    moduleIdentiferList.push(@moduleIdentifer)
    params =
      formData:{
        identifier:JSON.stringify(moduleIdentiferList)
      }
      sendCookie: true
      success: (data) =>
        console.log "check the last version of",@moduleIdentifer," | return data is ",data
        if data[0]['version']? and data[0]['version'] != ""
          console.log "the last version in server is ",data[0]['version']
        else
          data[0]['version'] = "0.0.0"
          # console.log data[0]['version']
        result = UtilExtend.checkUploadModuleVersion(@moduleUploadVersion.getText(),data[0]['version'])
        if result["error"]
          alert desc.uploadModuleVersionErrorTips
        else
          console.log "the module will be upload ."
          @fillMessageView.hide()
          @uploadProgressView.show()
          @parentView.prevBtn.addClass("hide")
          @parentView.nextBtn.addClass('hide')
          # 把模块name和模块版本写回文件
          @moduleId = data['module_id']
          obj = Util.readJsonSync @moduleConfPath
          if obj
            obj['name'] = @moduleName.getText()
            obj['version'] =@moduleUploadVersion.getText()
            fs.writeJsonSync @moduleConfPath,obj,null
            @moduleVersion = obj['version']
          # 压缩模块信息
          modulePath = PathM.join @moduleConfPath,".."
          Util.fileCompression(modulePath)
          moduleZipPath = modulePath+".zip"
          console.log moduleZipPath
          @callUploadModuleApi(moduleZipPath)
          # 调用模块上传接口  调通就todo 上传成功就跳到应用列表
          # @uploadProgressView.hide()
          # @moduleApplyView.show()
          #

      error:=>
        console.log "call the last version api fail"
    # 获取 该模块最新版本 和 build
    client.getModuleLastVersion(params)

  # thirdClickNext: ->
    # console.log @appPath.getText()
    # @initFirst(@appPath.getText())


  # initFirst:(appPath) ->
    # # console.log "init"
    # appPath = PathM.join appPath,@moduleLocatFileName
    # # directory = new Directory(appPath)
    # _moduleList = @moduleList
    # length = 0
    # _parentView = @parentView
    # printName = (filePath) =>
    #   # console.log filePath
    #   if filePath is ".gitHolder" || filePath is ".." || filePath is '.'
    #     return
    #   if fs.existsSync(filePath)
    #     stats = fs.statSync(filePath)
    #     # console.log "exists"
    #     if stats.isDirectory()
    #       # console.log "isDirectory"
    #       path =PathM.join filePath,@moduleConfigFileName
    #       # console.log path
    #       if fs.existsSync(path)
    #         # console.log "path exists"
    #         stats = fs.statSync(path)
    #         if stats.isFile()
    #           # console.log "is file"
    #           contetnList = JSON.parse(fs.readFileSync(path))
    #           # console.log contetnList
    #           # console.log contetnList['identifier'],contetnList['name']
    #           if contetnList['identifier']? and contetnList['name']?
    #             length = length + 1
    #             # console.log "length ++ "
    #             _moduleList.append('<div class="checkbox-layout"><div class="checkboxFive"><input id="'+path+'" value="'+path+'" type="checkbox" class="hide"><label for="'+path+'"></label></div><label for="'+path+'"class="label-empty">'+contetnList['name']+'</label></div>')
    # if fs.existsSync(appPath)
    #   stats = fs.statSync(appPath)
    #   if stats.isDirectory()
    #     list = fs.readdirSync(appPath)
    #     _moduleList.empty()
    #     printName PathM.join appPath,file for file in list
    #     # console.log length
    #     if length == 0
    #       _parentView.enable = false
    #       alert "没有任何模块"
    #       return
    #     @third.addClass('hide')
    #     @first.removeClass('hide')
    # else
    #   alert '不存在路径['+appPath+']'

  # nextStep: ->
  #   _parentView = @parentView
  #   # console.log 'click next button'
  #   if @third.hasClass('hide')
  #     console.log 'third is hide'
  #   else
  #     @thirdClickNext()
  #     return
  #   if @parentView.prevBtn.hasClass('hide')
  #     if this.find('input[type=checkbox]').is(':checked')
  #       console.log '选择了模块'
  #     else
  #       alert '你还没有选择模块。'
  #       return
  #     checkboxList = this.find('input[type=checkbox]')
  #     _moduleMessageList = @moduleMessageList
  #     _moduleMessageList.empty()
  #     # 输出模块选项
  #     moduleList = []
  #     modulePathJson = {}
  #     printModuleMessage = (checkbox) =>
  #       if $(checkbox).is(':checked')
  #         identifer =PathM.basename PathM.join $(checkbox).attr('value'),".."
  #         moduleList.push(identifer)
  #         modulePathJson[identifer] = $(checkbox).attr('value')
  #         _moduleMessageList.css({'width': moduleList.length * 240})
  #     printModuleMessage checkbox for checkbox in checkboxList
  #     params =
  #       formData:{
  #         identifier:JSON.stringify(moduleList)
  #       }
  #       sendCookie: true
  #       success: (data) =>
  #         console.log data
  #         errorMessage = "不存在路径"
  #         errorCode = 0
  #         html = ""
  #         showModuleMessage = (object) =>
  #           configPath = modulePathJson[object.identifier]
  #           if !fs.existsSync(configPath)
  #             errorCode = 1
  #           else
  #             stats = fs.statSync(configPath)
  #             if stats.isFile()
  #               contentList = JSON.parse(fs.readFileSync(configPath))
  #               # modulePath = PathM.join configPath,".."
  #               obj =
  #                 moduleName: contentList['name']
  #                 uploadVersion: contentList['version']
  #                 identifier: contentList['identifier']
  #                 version: contentList['serviceVersion']
  #                 modulePath: configPath
  #               # 获取版本 和 上传次数 ， 并判断和初始化  obj['build'] obj['version']
  #               if object['build']? and object['build'] != ""
  #                 obj["build"] = parseInt(object['build'])
  #               else
  #                 obj["build"] = 0
  #               if object['version']? and object['version'] != ""
  #                 obj['version'] = object['version']
  #               else
  #                 obj['version'] = "0.0.0"
  #               item = new ModuleMessageItem(obj)
  #               _moduleMessageList.append(item)
  #         showModuleMessage object for object in data
  #
  #       error : =>
  #         console.log "获取模板最新版本 的url 调不通"
  #     client.getModuleLastVersion(params)
  #     console.log moduleList
  #     console.log modulePathJson
  #     @second.removeClass('hide')
  #     @first.addClass('hide')
  #     @parentView.prevBtn.removeClass('hide')
  #     @parentView.nextBtn.text('完成')
  #   else
  #     @parentView.closeView()

  #初始化窗口
  attached: ->
    # @selectAppPathView.hide()
    @fillMessageView.hide()
    @uploadProgressView.hide()
    @moduleApplyView.hide()
    # @callGetAppListApi(1)
    projectPaths = atom.project.getPaths()
    projectNum = projectPaths.length
    @selectProject.empty()
    if projectNum isnt 0
      @setSelectItem path for path in projectPaths
    if @selectProject.children().length is 0
      optionStr = "<option value=' '> </option>"
      @selectProject.append optionStr
    optionStr = "<option value='其他'>其他</option>"
    @selectProject.append optionStr
    @selectProject.on 'change',(e) => @onSelectChange(e)
    console.log @selectLogo
    @selectLogo.on 'click', (e) => @selectIcon(e)

  # 模块Logo选择
  selectIcon:(e) ->
    img_path = PathM.join @selectProject.val(),"..",@moduleLogoFileName
    options={}
    cb = (selectPath) =>
      if selectPath? and selectPath.length != 0
        tmp = selectPath[0].substring(selectPath[0].lastIndexOf('.'))
        console.log tmp
        if tmp is ".jpeg" or tmp is ".png" or tmp is ".jpg"
          fs.writeFileSync(img_path,fs.readFileSync(selectPath[0]))
          @logo.attr("src",selectPath)
        else
          alert "请选择扩展名为 .jpeg 或者 .png 或者 .jpg"
          return
    Util.openFile options,cb

  #下拉框初始化  读取左边导航栏所有模块
  setSelectItem:(path) ->
    console.log "setSelectItem",path
    filePath = PathM.join path, @projectConfigFileName
    obj = Util.readJsonSync filePath
    if obj
      str = ""
      type = desc.appModule
      projectName = PathM.basename path
      addItem = (id,version) =>
        console.log id,version
        moduleConfigFile = PathM.join path,@moduleLocatFileName,id,@moduleConfigFileName
        obj2 = Util.readJsonSync moduleConfigFile
        modulePath = PathM.join path,@moduleLocatFileName,id
        console.log moduleConfigFile,obj2
        if obj2
          str = str + "<option value='#{moduleConfigFile}'>#{id} -- #{obj.name} : #{path}</option>"
      addItem id,version for id,version of obj['modules']
      console.log obj['modules']
      # optionStr = "<option value='#{path}'>#{projectName}  -  #{path}</option>"
      console.log str
      if str != ""
        @selectProject.append str
      return
    else
      filePath = PathM.join path, @moduleConfigFileName
      obj = Util.readJsonSync filePath
      type = desc.uAppModule
      if obj
        if obj['identifier']
          str = "<option value='#{path}'>#{obj.identifier} -- #{path}</option>"
          @selectProject.append str
      return

  #当选择其他时，弹出文件选择框
  onSelectChange: (e) ->
    el = e.currentTarget
    if el.value == '其他'
      @open()

  #文件夹选择窗
  open: ->
    atom.pickFolder (paths) =>
      if paths?
        path = PathM.join paths[0]
        console.log "path = ",path
        filePath = PathM.join path,@moduleConfigFileName
        console.log "filePath = ",filePath
        obj = Util.readJsonSync filePath
        type = desc.uAppModule
        if obj
          projectName = PathM.basename path
          optionStr = "<option value='#{path}'>#{type}:{#{obj['identifier']}} @{#{path}}</option>"
          @.find("select option[value=' ']").remove()
          @selectProject.prepend optionStr
        else
          alert desc.selectModuleErrorTips
        @selectProject.get(0).selectedIndex = 0
      else
        @selectProject.get(0).selectedIndex = 0


  # attached2: ->
  #   $('#tips').fadeOut()
  #   test = $('.entry.selected span')
  #   _parentView = @parentView
  #   _moduleList = @moduleList
  #   # console.log @flag.val()
  #   # console.log @parentView.flag
  #   if @parentView.flag is "select_path"
  #     # console.log "#{test.length}"
  #     @first.addClass('hide')
  #     @third.removeClass('hide')
  #     if @second.hasClass('hide')
  #       return
  #     else
  #       @second.addClass('hide')
  #       # @third.addClass('hide')
  #     return
  #   else
  #     project_path = $('.entry.selected span').attr('data-path')
  #     if @first.hasClass('hide')
  #       @first.removeClass('hide')
  #       @third.addClass('hide')
  #       @second.addClass('hide')
  #     #这是一个回调函数 的开始
  #     # console.log "hello"
  #     projectPaths = atom.project.getPaths()
  #     isRootNodeIsBSLProject = false
  #     rootPath = null
  #     checkContains = (path) =>
  #       directory = new Directory(path)
  #       if directory.contains(project_path)
  #         if UtilExtend.checkIsBSLProject(path)
  #           isRootNodeIsBSLProject = true
  #           rootPath = path
  #     checkContains path for path in projectPaths
  #     console.log isRootNodeIsBSLProject
  #     returnMessage = null
  #     returnStatus = false
  #     if fs.existsSync(project_path)
  #       projectStats = fs.statSync(project_path)
  #       #判断是否目录
  #       if projectStats.isDirectory()
  #         configFilePath = PathM.join project_path,@projectConfigFileName
  #         #判断  appConfig.json 是否存在
  #         if fs.existsSync(configFilePath)
  #           configFileStats = fs.statSync(configFilePath)
  #           file = new File(configFilePath)
  #           file.read(false).then (content) =>
  #             contentList = JSON.parse(content)
  #             $('#projectIdentifier').attr('value',contentList['identifier'])
  #           project_path = PathM.join project_path,@moduleLocatFileName
  #           if !fs.existsSync(project_path)
  #             # _parentView.enable = false
  #             returnMessage = "请选择变色龙应用（不存在modules文件）"
  #             returnStatus = true
  #           modulesStats = fs.statSync(project_path)
  #           if modulesStats.isFile()
  #             # _parentView.enable = false
  #             returnMessage = "请选择变色龙应用（不存在modules文件）"
  #             returnStatus = true
  #         else
  #           # _parentView.enable = false
  #           returnMessage = "请选择变色龙应用(不存在 appConfig.json)"
  #           returnStatus = true
  #       else
  #         # _parentView.enable = false
  #         returnMessage = "请选择变色龙应用"
  #         returnStatus = true
  #     else
  #       _parentView.enable = false
  #       alert "文件不存在"
  #       return
  #     if returnStatus
  #       if isRootNodeIsBSLProject
  #         project_path = rootPath
  #         project_path = PathM.join project_path,@moduleLocatFileName
  #         if !fs.existsSync(project_path)
  #           _parentView.enable = false
  #           alert returnMessage
  #           return
  #         modulesStats = fs.statSync(project_path)
  #         if modulesStats.isFile()
  #           _parentView.enable = false
  #           alert returnMessage
  #           return
  #       else
  #         _parentView.enable = false
  #         alert returnMessage
  #         return
  #     modulesCount = 0
  #     list = fs.readdirSync(project_path)
  #     fileLength = 0
  #     printName = (filePath) =>
  #       console.log fileLength
  #       stats = fs.statSync(filePath)
  #       if stats.isDirectory()
  #         basename = PathM.basename filePath
  #         packageFilePath = PathM.join filePath,@moduleConfigFileName
  #         if fs.existsSync(packageFilePath)
  #           # alert "#{packageFilePath}"
  #           packageFileStats = fs.statSync(packageFilePath)
  #           if packageFileStats.isFile()
  #             fileLength = fileLength + 1
  #             getMessage = (err, data) =>
  #               if err
  #                 console.log "error"
  #               else
  #                 contentList = JSON.parse(data)
  #                 _moduleList.append('<div class="checkbox-layout"><div class="checkboxFive"><input id="module-upload'+basename+'" value="'+packageFilePath+'" type="checkbox" class="hide" /><label for="module-upload'+basename+'"></label></div><label for="module-upload'+basename+'" class="label-empty">'+contentList['name']+'</label></div>')
  #                 # console.log data
  #             options =
  #               encoding: "UTF-8"
  #             fs.readFile(packageFilePath,options,getMessage)
  #     _moduleList.empty()
  #     printName PathM.join project_path,fileName for fileName in list
  #     if fileLength == 0
  #       _parentView.enable = false
  #       alert "没有任何模块"
  #       return

  getElement: ->
    @element

module.exports =
class PublishModuleView extends ChameleonBox
  setOptions:(flag) ->
    @flag = flag
  options :
    title : desc.publishModule
    subview :  new PublishModuleInfoView()
