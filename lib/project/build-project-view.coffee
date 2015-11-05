{$,TextEditorView,View} = require 'atom-space-pen-views'
pathM = require 'path'
desc = require './../utils/text-description'
Util = require './../utils/util'
ChameleonBox = require '../utils/chameleon-box-view'
fs = require 'fs-extra'
client = require '../utils/client'
UtilExtend = require './../utils/util-extend'

qrCode = require 'qrcode-npm'

class BuildProjectInfoView extends View
  checkBuildResultTimer: {}
  ticketTimer:{}
  buildPlatformId:{}
  moduleConfigFileName: desc.moduleConfigFileName
  projectConfigFileName: desc.projectConfigFileName
  moduleLogoFileName: desc.moduleLogoFileName
  moduleLocatFileName: desc.moduleLocatFileName
  selectProjectTxt:"请选择变色龙项目"
  selectModuleTxt:"请选择主模块"
  projectPath:null #项目的路径
  engineType:"PUBLIC"
  buildPlatform:"iOS"   # 对应构建应用的 platform
  engineVersionList:[]
  imageList:{}          # 对应构建应用的 images
  projectConfigContent:null
  projectLastContent:null
  projectIdFromServer:null
  logoImage:null        # 对应构建应用的 logoFileId
  moduleList :{}        # 对应构建应用的 moduleList 不过需要转一下格式 []
  pluginList:{}         # 对应构建应用的 pluginList 不过需要转一下格式 []
  mainModuleId:null     # 对应构建应用的 mainModuleId
  pageSize:4
  pageIndex:1
  engineId:null
  pageTotal:1
  projectId:null
  httpType:"http"
  engineMessage:null
  buildingId:null
  timer:null
  buildStep:1 #1、表示上传图片 2、表示调构建接口 3、表示见识构建结果 4、表示显示结果
  step:1 #1、代表第一步选择应用  2、为选择选择平台 3、为选择引擎 4、为选择引擎的版本 5、为引擎基本信息
         #6、应用基本信息，上传各个分辨率的封面图片  7、 选择模块 8、选择插件 9、证书管理 10、构建预览
  #分页都还没做

  @content: ->
    @div class: 'build_project_view', =>
      @div outlet: 'selectProjectView', class:'form-horizontal form_width',=>
        @label '选择构建的应用', class: 'label-width control-label'
        @div class: 'input-width', =>
          @select class: '', outlet: 'selectProject'
      @div outlet: 'platformSelectView',class:'form-horizontal form_width', =>
        @div class: 'col-xs-12', =>
          @label "选择需要构建的应用平台",class:"title-2-level"
        @div class: 'col-xs-6 text-center padding-top', =>
          @div class: 'col-xs-12 text-center', =>
            @div class: 'selectBuildTemplate active',value:'iOS', =>
              @img outlet:'iosIcon',src: desc.getImgPath 'icon_apple.png'
            @div class: "",=>
              @label "iOS"
        @div class: 'col-xs-6 text-center padding-top', =>
          @div class: 'col-xs-12 text-center', =>
            @div class: 'selectBuildTemplate',value:'Android', =>
              @img outlet:'androidIcon',src: desc.getImgPath 'icon_android.png'
            @div class: "",=>
              @label "Android"
      @div outlet:"engineTableView",class:'form-horizontal form_width', =>
        @div class: "col-xs-12", =>
          @label "引擎选择",class:"title-2-level"
        @div class: "col-xs-12", =>
          @label "共有引擎", value:"PUBLIC" ,class:"public-view click-platform platformBtn",click:"platformBtnClick"
          @label "私有引擎", value:"PRIVATE",class:"private-view platformBtn",click:"platformBtnClick"
          @div class:"div-table-view", =>
            @table =>
              @thead =>
                @tr =>
                  @th "标识",class:"th-identify"
                  @th "平台",class:"th-platform"
                  @th "引擎名称",class:"th-engine"
                  @th "描述",class:"th-desc"
                  # @th "引擎大小",class:"th-width-50"
                  @th "更新时间",class:"th-update-time"
                  @th "操作"
              @tbody outlet:"engineItemShowView" #=>
                # @tr =>
                #   @td "com.foreveross.codorva"
                #   @td "Android"
                #   @td "app 通用引擎"
                #   @td "支持Android 5.0 , 内置 codova 4.0"
                #   @td "10M"
                #   @td "2015-09-18 13:00:00"
                #   @td =>
                #     @button "选择"
          @div class: "",=>
            @button "上一页",class:"btn engineListClass prevPageButton"
            @button "下一页",class:"btn engineListClass nextPageButton"
      @div outlet:"engineVersionView",class:'form-horizontal form_width',=>
        @div =>
          @label "引擎版本选择:"
          @label outlet:"enginName"
        @div  =>
          @table =>
            @thead =>
              @tr =>
                @th "版本",class:"th-engine"
                @th "文件大小",class:"th-engine"
                @th "发布时间",class:"th-desc"
                @th "更新内容",class:"th-desc"
                @th "操作"
            @tbody outlet:"engineVersionItemView" #=>
              # @tr =>
              #   @td "1.0.1"
              #   @td "10M"
              #   @td "2015-08-15 17:30"
              #   @td "支持 codorva 5.0"
              #   @td =>
              #     @a "选择"
        @div class: "",=>
          @button "上一页",class:"btn engineVersionListClass prevPageButton"
          @button "下一页",class:"btn engineVersionListClass nextPageButton"

      @div outlet:"engineBasicMessageView",class:"form-horizontal form_width engineBasicMessageView",=>
        @div class: "col-xs-12", =>
          @label "引擎配置"
        @div class:"col-xs-12",=>
          @label "引擎:"
          @label outlet:"engineName"
        @div class:"col-xs-12",=>
          @label "标识:"
          @label outlet:"engineIdView"
        @div class:"col-xs-12",=>
          @div class:"div-engine-basic",=>
            @label "平台:"
            @label outlet:"platform"
          @div class:"div-engine-basic",=>
            @label "引擎大小:"
            @label outlet:"engineSize"
        @div class:"col-xs-12",=>
          @label "构建环境:"
          @label outlet:"buildEnv"
        @div class:"col-xs-12",=>
          @label "版本:"
          @label outlet:"engineVersion"
        @div class:"col-xs-12",=>
          @label "横竖屏支持:"
          @input type:"checkbox" ,value:"scross",class:"showStyle"
          @label "横屏"
          @input type:"checkbox" ,value:"vertical",class:"showStyle"
          @label "竖屏"
        @div class:"col-xs-12 iOSSupportView",=>
          @label "硬件支持:"
          @input type:"checkbox" ,value:"iPhone",class:"supportMobileType"
          @label "iPhone"
          @input type:"checkbox" ,value:"iPad",class:"supportMobileType"
          @label "iPad"
      @div outlet:"projectBasicMessageView",class:"form-horizontal form_width",=>
        @div class: "col-xs-12", =>
          @div class:"" ,=>
            @label "APP LOGO", class:"label-logo"
            @img outlet:"logo",class:'pic img-logo', src: desc.getImgPath 'select-logo.png'
          # @div =>
          #   @button "上传", outlet:"selectLogo",class:"btn btn-width btn-logo selectImageItem"
          @div =>
            @div =>
              @label
            @div =>
              @div class:"verticalModelView",=>
                @label "竖屏"
                @div outlet:"verticalModelView"
              @div class:"scrossModelView",=>
                @label "横屏"
                @div outlet:"scrossModelView"

      @div outlet:"selectModuleView",class:"form-horizontal form_width", =>
        @div =>
          @label "关联模块",class:"title-2-level"
        @div =>
          @div =>
            @label "主模块:"
            @label outlet:"mainModuleTag"
          @div =>
            @label "已选模块:"
            @label outlet:"modulesTag"
        @div =>
          @table =>
            @thead =>
              @tr =>
                @th "名字",class:"th-desc"
                @th "版本",class:"th-desc"
                @th "操作"
            @tbody outlet:"modulesShowView",class:"modulesShowView"
        @div class: "",=>
          @button "上一页",class:"btn moduleListClass prevPageButton"
          @button "下一页",class:"btn moduleListClass nextPageButton"
      @div outlet:"selectPluginView",class:"form-horizontal form_width", =>
        @div =>
          @label "关联插件",class:"title-2-level"
        @div =>
          @label "已关联的插件:"
          @label outlet:"pluginsTag"
        @div =>
          @table =>
            @thead =>
              @tr =>
                @th "名字"
                @th "版本"
                @th "操作"
            @tbody outlet:"pluginsShowView",class:"pluginsShowView"
        @div class: "",=>
          @button "上一页",class:"btn pluginListClass prevPageButton"
          @button "下一页",class:"btn pluginListClass nextPageButton"
      @div outlet:"certSelectView",class:"form-horizontal form_width",=>
        @div =>
          @label "证书管理",class:"title-2-level"
        @div outlet:"androidCertSelectView", =>
          @div class:"", =>
            @label "Android证书"
          @div class:"border-style",=>
            @div class:"col-xs-12",=>
              @label "Keystore别名" ,class:"certInfo-label"
              @div class: 'inline-view', =>
                @subview 'keystoreName', new TextEditorView(mini: true,placeholderText: 'moduleName...')
            @div class:"col-xs-12", =>
              @label "Android证书文件",class:"certInfo-label"
              @div class: 'inline-view', =>
                @subview 'keystoreName', new TextEditorView(mini: true,placeholderText: 'moduleName...')
            @div class:"col-xs-12", =>
              @label "Android证书存储库口令",class:"certInfo-label"
              @div class: 'inline-view', =>
                @subview 'keystoreName', new TextEditorView(mini: true,placeholderText: 'moduleName...')
            @div class:"col-xs-12", =>
              @label "Android证书密钥库口令",class:"certInfo-label"
              @div class: 'inline-view', =>
                @subview 'keystoreName', new TextEditorView(mini: true,placeholderText: 'moduleName...')
            @div class:"col-xs-12 text-right-align",=>
              @button "检验证书",class:"btn"
        @div outlet:"iosCertSelectView", =>
          @div =>
            @label "iOS发布证书",class:"iOSPersonCert iOSCertTh "
            @label "iOS企业证书",class:"companyPersonCert iOSCertTh "
          @div class:"border-style", =>
            @div class:"col-xs-12",=>
              @label "App ID",class:"certInfo-label"
              @div class: 'inline-view', =>
                @subview 'keystoreName', new TextEditorView(mini: true,placeholderText: 'moduleName...')
            @div class:"col-xs-12",=>
              @label "发布证书",class:"certInfo-label"
              @div class: 'inline-view', =>
                @subview 'keystoreName', new TextEditorView(mini: true,placeholderText: 'moduleName...')
            @div class:"col-xs-12",=>
              @label "证书密码",class:"certInfo-label"
              @div class: 'inline-view', =>
                @subview 'keystoreName', new TextEditorView(mini: true,placeholderText: 'moduleName...')
            @div class:"col-xs-12",=>
              @label "证书解释文件",class:"certInfo-label"
              @div class: 'inline-view', =>
                @subview 'keystoreName', new TextEditorView(mini: true,placeholderText: 'moduleName...')
            @div class:"col-xs-12 text-right-align",=>
              @button "检验证书",class:"btn"
      @div outlet:"buildReView", =>
        @button "生成安装包",click:"buildAppMethod"
      @div outlet:"buildAppView", =>
        @div outlet:"uploadImageStepView" ,=>
          @label "正在上传图片..."
        @div outlet:"sendBuildRequestView", =>
          @label "正在请求构建,请耐心等待..."
        @div outlet:"waitingBuildResultView", =>
          @label outlet:"buildingTips"
          # @label outlet:"needTime"
        @div outlet:"buildResultView" , =>
          @div =>
            @img outlet:"imgForDownloadApp"
            @a outlet:"urlForDownloadApp"

  # 点击平台图片触发事件
  clickIcon:(e) ->
    el = e.currentTarget
    console.log $(el).attr('value')
    @buildPlatform = $(el).attr('value')
    @.find(".selectBuildTemplate").removeClass("active")
    $(el).addClass("active")

  # 点击平台按钮事件
  platformBtnClick:(m1,b1) ->
    @engineType = $(b1).attr("value")
    console.log $(b1).attr("value"),@engineType
    @.find(".platformBtn").removeClass("click-platform")
    $(b1).addClass("click-platform")
    @initEngineTableView()

  # 初始化
  attached: ->
    # UtilExtend.dateFormat("YYYY-MM-DD HH:mm:ss",new Date())
    # @selectProjectView.hide()
    # console.log @getImageUrlMethod("qdt_icon_10hdhsdhjasgf",0)
    # console.log @getImageUrlMethod("10hdhsdhjasgf")
    @platformSelectView.hide()
    @engineTableView.hide()
    @engineVersionView.hide()
    @engineBasicMessageView.hide()
    @projectBasicMessageView.hide()
    @selectModuleView.hide()
    @selectPluginView.hide()
    @certSelectView.hide()
    @buildReView.hide()
    @buildAppView.hide()
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
    @.find('.formBtn').on 'click', (e) => @formBtnClick(e)
    @.find('.selectBuildTemplate').on 'click',(e) => @clickIcon(e)
    # 绑定点击上一页下一页事件
    @.find('.prevPageButton').on 'click',(e) => @prevPageClick(e)
    @.find('.nextPageButton').on 'click',(e) => @nextPageClick(e)
    @.find('.iOSCertTh').on 'click',(e) => @clickIosCert(e)

  # 点击下一步按钮触发事件
  nextBtnClick:() ->
    if @step is 1   #1、代表第一步选择应用
      if @projectPath isnt @selectProject.val()
        @mainModuleTag.html("")
        @modulesTag.html("")
      @projectPath = @selectProject.val()
      console.log @step,@projectPath
      @platformSelectView.show()
      @selectProjectView.hide()
      @parentView.prevBtn.show()
      @parentView.prevBtn.attr('disabled',false)
      # @getProjectId()
      @step = 2
    else if @step is 2 #2、为选择选择平台
      console.log @step,@buildPlatform
      @platformSelectView.hide()
      @engineTableView.show()
      @initEngineTableView()
      @step = 3
    else if @step is 4 #4、为选择引擎的版本  这个已经没用了
      @engineVersionView.hide()
      @engineBasicMessageView.show()
      @getBasicMessageView()
      @step = 5
    else if @step is 3 #3、为选择引擎
      console.log "show engin basic message"
      @engineTableView.hide()
      @engineBasicMessageView.show()
      @getBasicMessageView()
      @step = 5
    else if @step is 5 # 5、为引擎基本信息
      if @.find(".showStyle:checked").length is 0
        alert desc.projectTipsStep5_1
        return
      if @buildPlatform is "iOS"
        if @.find(".supportMobileType:checked").length is 0
          alert desc.projectTipsStep5_2
          return
      @engineBasicMessageView.hide()
      @projectBasicMessageView.show()
      @initProjectBasicMessageViewStep5_1()
      @step = 6
    else if @step is 6 # 6、模块选择
      # callBack = =>
      @projectBasicMessageView.hide()
      @selectModuleView.show()
      @pageSize = 4
      @pageIndex = 1
      @initSelectModuleView([],@pageIndex,@pageSize)
      @step = 7
      # @uploadFileSync(callBack)
    else if @step is 7 # 7、插件选择
      if !@mainModuleId
        alert @selectModuleTxt
        return
      @pageSize = 4
      @pageIndex = 1
      @selectModuleView.hide()
      @selectPluginView.show()
      @initSelectPluginView([],@pageIndex,@pageSize)
      @step = 8
    else if @step is 8 # 8、
      @selectPluginView.hide()
      @initCertView()
      @certSelectView.show()
      @step = 9
    else if @step is 9
      @certSelectView.hide()
      @buildReView.show()
      @step = 10
      @parentView.nextBtn.hide()

  #初始化证书选择
  initCertView:() ->
    if @buildPlatform is "iOS"
      @androidCertSelectView.hide()
      @iosCertSelectView.show()
      @.find(".companyPersonCert").addClass("click-cert-label")
    else
      @iosCertSelectView.hide()
      @androidCertSelectView.show()

  clickIosCert:(e) ->
    console.log "xss"
    el = e.currentTarget
    if $(el).hasClass("click-cert-label")
      @.find('.iOSCertTh').addClass("click-cert-label")
      $(el).removeClass("click-cert-label")

  #上传logo的图片
  uploadFileSync:(callBack) ->
    @buildReView.hide()
    @uploadImageStepView.show()
    @sendBuildRequestView.hide()
    @waitingBuildResultView.hide()
    @buildResultView.hide()
    @buildAppView.show()
    if fs.existsSync(@logoImage)
      params =
        formData: {
          up_file: fs.createReadStream(@logoImage)
        }
        sendCookie:true
        success:(data) =>
          # console.log data
          @logoImage = data["url_id"]
          keyArray = []
          getKeyList = (key,path) =>
            keyArray.push(key)
          getKeyList key,path for key,path of @imageList
          console.log callBack
          @uploadImageFileListSync(keyArray,0,callBack)
        error:(msg) =>
          console.log msg
      client.uploadFileSync(params,"qdt_app",true)
    else
      keyArray = []
      getKeyList = (key,path) =>
        keyArray.push(key)
      getKeyList key,path for key,path of @imageList
      console.log callBack
      @uploadImageFileListSync(keyArray,0,callBack)

  # 同步上传文件
  uploadImageFileListSync:(keyArray,index,callBack)->
    if keyArray.length > index
      key = keyArray[index]
      path = @imageList["#{key}"]
      if fs.existsSync(path)
        params =
          formData: {
            up_file: fs.createReadStream(path)
          }
          sendCookie:true
          success:(data) =>
            @imageList["#{key}"] = data["url_id"]
            @uploadImageFileListSync(keyArray,index+1,callBack)
          error:(msg) =>
            console.log msg
        client.uploadFileSync(params,"qdt_app",true)
      else
        @uploadImageFileListSync(keyArray,index+1,callBack)
    else
      callBack()

  buildAppMethod:() ->
    callBack = =>
      @uploadImageStepView.hide()
      @sendBuildRequestView.show()
      platform = "IOS"
      if @buildPlatform is "Android"
        platform = "ANDROID"
      data = {}
      certInfo =
        "certSystem":platform
        "appId":@projectId
        "certAlias":""  #ios 与android有区别
      data["certInfo"] = certInfo
      data["platform"] = platform
      data["appId"] = @projectId
      data["identifier"] = @projectConfigContent["identifier"]
      data["logoFileId"] = @logoImage
      data["classify"] = "appdisplay" #可不填
      data["status"] = "OFFLINE" #
      data["appName"] = @projectConfigContent["name"]
      data["version"] = "3.0.0"
      data["createTime"] = UtilExtend.dateFormat("YYYY-MM-DD HH:mm:ss",new Date()) #当前时间
      data["images"] = @imageList #文件id
      modules = []
      formatModuleList = (key,item) =>
        tmp =
          "moduleVersionId":item["moduleVersionId"]
          "moduleId": item["moduleId"]
          "appVersionId":""
          "appId":""
        modules.push(tmp)
      formatModuleList key,item for key,item of @moduleList
      plugins = []
      formatPlugineList = (key,item) =>
        tmp =
          "pluginVersionId":item["pluginVersionId"]
          "pluginId": item["pluginId"]
          "appVersionId":""
          "appId":""
        plugins.push(tmp)
      formatPluginList key,item for key,item of @pluginList
      data["moduleList"] = modules
      data["pluginList"] = plugins
      data["mainModuleId"] = @mainModuleId
      data["engineId"] = @engineMessage["engineId"]
      data["engineVersionId"] = @engineMessage["id"]
      console.log data
      params =
        sendCookie:true
        body: JSON.stringify(data)
        success:(data) =>
          console.log "requestBuildApp data = #{data}"
          @buildingId = data["buildId"]
          # TODO: 监听构建结果
          @sendBuildRequestView.hide()
          @waitingBuildResultView.show()
          @checkBuildStatusByBuildId(@buildingId)
        error:(msg) =>
          console.log msg
      client.requestBuildApp(params)
    @uploadFileSync(callBack)

  checkBuildStatusByBuildId:(buildingId)->
    params =
      sendCookie:true
      success:(data) =>
        console.log data
        waitTime = 0
        if data["code"] == -1
          alert "构建不存在"
          return
        if data["status"] == "WAITING"
          waitTime = data["waitingTime"]
          if waitTime == 0
            @buildingTips.html("准备开始构建...")
          else
            @buildingTips.html("还需等待构建<span class='waitTime'>#{waitTime}</span>秒")
          loopTime = 25 # 调服务器时间 的时间间隔
          if waitTime < loopTime
            loopTime = waitTime
            if waitTime == 0
              loopTime = loopTime + 2
        else if data["status"] == "BUILDING"
          waitTime = data['remainTime']
          @buildingTips.html("正在构建<span class='waitTime'>#{waitTime}</span>秒")
          loopTime = 25
          if waitTime < loopTime
            loopTime = waitTime
        else if data["status"] == "SUCCESS"
          @waitingBuildResultView.hide()
          @buildResultView.show()
          qr1 = qrCode.qrcode(8, 'L')
          qr1.addData(data['url'])
          qr1.make()
          img1 = qr1.createImgTag(4)
          @imgForDownloadApp.attr("src",$(img1).attr('src'))
          @urlForDownloadApp.attr('href',data['url'])
          @urlForDownloadApp.html("app下载地址")
        else
          alert "构建失败"
          return
        @timer = setTimeout =>
          @timerMethod buildingId,loopTime
        ,1000
      error:(msg) =>
        console.log msg
    client.getBuildUrl(params,buildingId)

  timerMethod: (buildingId,loopTime) ->
    if loopTime <= 0
      @checkBuildStatusByBuildId(buildingId)
    else
      number = parseInt(@.find(".waitTime").html()) - 1
      @.find(".waitTime").html(number)
      loopTime = loopTime - 1
      @timer = setTimeout =>
        @timerMethod buildingId,loopTime
      ,1000

  # 初始化插件
  # array 需要过滤掉的插件数据
  initSelectPluginView:(array,pageIndex,pageSize) ->
    console.log "begin to initSelectPluginView"
    platform = "ANDROID"
    if @buildPlatform is "iOS"
      platform = "IOS"
    exceptModuleArray = array
    params =
      sendCookie:true
      success:(data) =>
        console.log data
        if data['totalCount'] <= pageIndex*@pageSize
          @.find(".engineListClass.nextPageButton").attr("disabled",true)
        else
          @.find(".engineListClass.nextPageButton").attr("disabled",false)
        if data["totalCount"] > 0
          console.log data["datas"]
          @initPluginViewTableBody(data["datas"])
        else
          console.log "没有任何插件"
      error:(msg) =>
        console.log "initSelectPluginView api error = #{msg}"
    client.getPluginList(params,platform,"PRIVATE",exceptModuleArray.join(","),pageIndex,pageSize)

  initPluginViewTableBody:(data) ->
    htmlArray = []
    getHtmlItem = (item) =>
      selectItem = []
      getChildOptions = (optionItem) =>
        optionStr = """
        <option value="#{optionItem["value"]}">#{optionItem["text"]}</option>
        """
        selectItem.push(optionStr)
      getChildOptions optionItem for optionItem in item["versions"]
      str = """
      <tr>
        <td><span class="#{item["id"]}">#{item["name"]}</span></td>
        <td>
            <select class="#{item["id"]}">
              #{itemArray.join("")}
            </select>
        </td>
        <td>
        <button value="#{item["id"]}">选择</button>
        <button value="#{item["id"]}" class="cancelSelect">取消</button>
        </td>
      </tr>
      """
      htmlArray.push(str)
    getHtmlItem item for item in data
    @pluginsShowView.html(htmlArray.join(""))
  #初始化模块
  initSelectModuleView:(array,pageIndex,pageSize)->
    console.log "begin to initSelectModuleView"
    platform = "ANDROID"
    if @buildPlatform is "iOS"
      platform = "IOS"
    exceptModuleArray = array
    params =
      sendCookie:true
      success:(data)=>
        # console.log data
        if data['totalCount'] <= pageIndex*@pageSize
          @.find(".engineListClass.nextPageButton").attr("disabled",true)
        else
          @.find(".engineListClass.nextPageButton").attr("disabled",false)
        if data["totalCount"] > 0
          htmlArray = []
          getHtmlItem = (item) =>
            itemArray = []
            # 获取下拉框的选项
            getChildOptions = (optionItem) =>
              optionStr = """
              <option value="#{optionItem["value"]}">#{optionItem["text"]}</option>
              """
              itemArray.push(optionStr)
            getChildOptions optionItem for optionItem in item["versions"]
            # 拼接tr
            str = """
            <tr>
              <td><span class="#{item["id"]}">#{item["name"]}</span></td>
              <td>
                  <select class="#{item["id"]}">
                    #{itemArray.join("")}
                  </select>
              </td>
              <td>
              <a value="#{item["id"]}" class="a-padding">选择</a>
              <a value="#{item["id"]}" class="mainModuleTag a-padding">主模块</a>
              <a value="#{item["id"]}" class="cancelSelect a-padding">取消</a>
              </td>
            </tr>
            """
            htmlArray.push(str)
          getHtmlItem item for item in data["datas"]
          @modulesShowView.html(htmlArray.join(""))
          # 点击模块button按钮触发事件
          clickModuleShowViewBtn = (e) =>
            el = e.target
            # ell = e.currentTarget
            # className = el.attr("value")
            # console.log el
            className = $(el).attr("value")
            moduleName = @.find("span.#{className}").html()
            moduleVersionId = @.find("td>select.#{className}").val()
            moduleVersion = @.find("td>select.#{className}>option[value=#{moduleVersionId}]").html()
            # console.log moduleName+":"+moduleVersion
            # console.log moduleVersionId
            @moduleList[moduleName] =
              "moduleVersionId": moduleVersionId
              "moduleId":className
              "appVersionId":""
              "appId":""
              "name":moduleName
              "moduleVersion":moduleVersion
            # console.log @moduleList
            if $(el).hasClass("mainModuleTag")
              @mainModuleId = className
            else if $(el).hasClass("cancelSelect")
              delete @moduleList[moduleName]
            # view
            mainModuleStr = ""
            modulesTagArray = []
            showHtmlView = (key,item) =>
              # console.log  "item = #{item}"
              str = """
              <span> #{item["name"]}:#{item["moduleVersion"]} </span>
              """
              modulesTagArray.push(str)
              if item["moduleId"] is @mainModuleId
                mainModuleStr = str
            showHtmlView key,item for key,item of @moduleList
            if mainModuleStr is ""
              @mainModuleId = null
            # console.log @moduleList
            @mainModuleTag.html(mainModuleStr)
            @modulesTag.html(modulesTagArray.join(""))
          @.find(".modulesShowView").on "click","a",(e) => clickModuleShowViewBtn(e)
        else
          alert "没有模块"
      error:(msg) =>
        console.log "initSelectModuleView api error = #{msg}"
    client.getModuleList(params,platform,"PRIVATE",exceptModuleArray.join(","),pageIndex,pageSize)

  # 获取上一次构建时的信息
  getLastBuildMessage:()->
    params =
      sendCookie:true
      success:(data) =>
        console.log data
        @projectLastContent = data
        @initProjectBasicMessageViewStep5_2()
      error: (msg) =>
        console.log msg
        @initProjectBasicMessageViewStep5_2()
    client.getLastBuildProjectMessage(params,@projectIdFromServer,@buildPlatform)

  # 获取应用ID 如果应用ID不存在则判断为
  getProjectId: () ->
    filePath = pathM.join @projectPath,@projectConfigFileName
    if !fs.existsSync(filePath)
      alert "本地应用配置文件不存在"
      return
    @projectConfigContent = Util.readJsonSync filePath
    if !@projectConfigContent["identifier"] or typeof(@projectConfigContent["identifier"]) == undefined
      alert "本地配置文件有缺损"
      return
    params =
      sendCookie: true
      success: (data) =>
        console.log data
        @projectIdFromServer = data["id"]
        @getLastBuildMessage()
        # @projectConfigContent["id"] =
        #如果data存在则从中获取 projectId
      error:(msg) =>
        @initProjectBasicMessageViewStep5_2()
        console.log msg
    client.getAppIdByAppIndentifer(params,"com.hover.cyz.test")

  #初始化基本信息，也就
  initProjectBasicMessageViewStep5_1:()->
    @projectLastContent = null
    console.log "projectBasicMessageView is show"
    @getProjectId()

  #显示内容
  initProjectBasicMessageViewStep5_2:()->
    showStyleArray = []
    # 如果获取到了上一次构建时的信息则执行这一步
    if @projectLastContent
      @logo.attr("src",@getImageUrlMethod(@projectLastContent["base"]["logoFileId"]))
    getShowStyle = (item) ->
      showStyleArray.push(item.value)
    getShowStyle item for item in @.find(".showStyle:checked")
    supportMobileTypeArray = []
    if @buildPlatform is "iOS"
      getShowStyle = (item) ->
        supportMobileTypeArray.push(item.value)
      getShowStyle item for item in @.find(".supportMobileType:checked")
    else
      supportMobileTypeArray.push("Android")
    isNeedHide = 0 # 0表示需要把横竖屏都隐藏，1表示隐藏横屏，2表示隐藏竖屏，3表示不隐藏
    showView = (item) =>
      if item is "vertical"
        if isNeedHide is 0
          isNeedHide = 1
        else
          isNeedHide = 3
        htmlVerticalArray = []
        getVerticalStr = (item1) =>
          if item1 is "iPad"
            console.log "getIPadVerticalHtml"
            htmlVerticalArray.push(@getIPadVerticalHtml())
          else if item1 is "iPhone"
            console.log "getIPhoneVerticalHtml"
            htmlVerticalArray.push(@getIPhoneVerticalHtml())
          else
            console.log "getAndroidVerticalHtml"
            htmlVerticalArray.push(@getAndroidVerticalHtml())
        getVerticalStr item1 for item1 in supportMobileTypeArray
        @.find(".verticalModelView").show()
        console.log htmlVerticalArray.join("")
        @verticalModelView.html(htmlVerticalArray.join(""))
      else
        if isNeedHide is 0
          isNeedHide = 2
        else
          isNeedHide = 3
        htmlScrossArray = []
        getScrossStr = (item2) =>
          if item2 is "iPad"
            console.log "getIPadScrossHtml"
            htmlScrossArray.push(@getIPadScrossHtml())
          else if item2 is "iPhone"
            console.log "getIPhoneScrossHtml"
            htmlScrossArray.push(@getIPhoneScrossHtml())
          else
            console.log "getAndroidScrossHtml"
            htmlScrossArray.push(@getAndroidScrossHtml())
        getScrossStr item2 for item2 in supportMobileTypeArray
        @.find(".scrossModelView").show()
        console.log htmlScrossArray.join("")
        @scrossModelView.html(htmlScrossArray.join(""))
    showView item for item in showStyleArray
    @.find("img").on "click",(e) => @selectImg(e)
    # 隐藏不必要的显示
    if isNeedHide is 0
      @.find(".verticalModelView").hide()
      @.find(".scrossModelView").hide()
    else if isNeedHide is 1
      @.find(".scrossModelView").hide()
    else if isNeedHide is 2
      @.find(".verticalModelView").hide()
    # @getProjectId()

  # 点击图片,按下一步后就上传图片
  selectImg:(e) ->
    options = {}
    el = e.currentTarget
    cb = (selectPath) =>
      if selectPath? and selectPath.length != 0
        tmp = selectPath[0].substring(selectPath[0].lastIndexOf('.'))
        console.log tmp
        if tmp is ".png"
          $(el).attr("src",selectPath[0])
          if $(el).hasClass("img-logo")
            @logoImage = selectPath[0]
          else
            @imageList[$(el).attr("value")] = selectPath[0]
          console.log @imageList
        else
          alert desc.projectTipsStep6_selectImg
    Util.openFile options,cb

  # 点击上一步按钮触发事件
  prevBtnClick:() ->
    console.log "prevBtnClick"
    if @step is 2
      # console.log "prevBtnClick"
      @platformSelectView.hide()
      @selectProjectView.show()
      @parentView.prevBtn.hide()
      @step = 1
    else if @step is 3
      @engineTableView.hide()
      @platformSelectView.show()
      @step = 2
    else if @step is 4
      @engineVersionView.hide()
      @engineTableView.show()
      @step = 3
    else if @step is 5
      @engineBasicMessageView.hide()
      @engineTableView.show()
      @step = 3
    else if @step is 6
      @projectBasicMessageView.hide()
      @engineBasicMessageView.show()
      @step = 5
    else if @step is 7
      @selectModuleView.hide()
      @projectBasicMessageView.show()
      @step = 6
    else if @step is 8
      @selectPluginView.hide()
      @selectModuleView.show()
      @step = 7
    else if @step is 9
      @certSelectView.hide()
      @selectPluginView.show()
      @step = 8
    else if @step is 10
      @buildReView.hide()
      @certSelectView.show()
      @parentView.nextBtn.show()
      @step = 9

  getList:(el,pageIndex,pageSize) ->
    if $(el).hasClass("engineListClass")
      @getApiEngingList(pageIndex,pageSize)
    else if $(el).hasClass("engineVersionListClass")
      @getEngineVersionList(pageIndex,pageSize)
    else if $(el).hasClass("moduleListClass")
      @initSelectModuleView([],pageIndex,pageSize)
    else if $(el).hasClass("pluginListClass")
      @initSelectPluginView([],pageIndex,pageSize)
  # 点击下一页所触发的事件
  nextPageClick:(e) ->
    el = e.currentTarget
    @pageIndex = @pageIndex + 1
    console.log @pageIndex
    @getList(el,@pageIndex,@pageSize)
  # 点击上一页所触发的事件
  prevPageClick:(e) ->
    el = e.currentTarget
    if @pageIndex > 1
      @pageIndex = @pageIndex - 1
    else
      @pageIndex = 1
      return
    console.log @pageIndex
    @getList(el,@pageIndex,@pageSize)

  # 获取引擎列表
  getApiEngingList:(pageIndex,pageSize) ->
    platform = "IOS"
    if @buildPlatform is "Android"
      platform = "ANDROID"
    params =
      sendCookie: true
      success:(data) =>
        # console.log data
        # 判断是否没有下一页了
        if data['totalCount'] <= pageIndex*@pageSize
          @.find(".engineListClass.nextPageButton").attr("disabled",true)
        else
          @.find(".engineListClass.nextPageButton").attr("disabled",false)
        if data['totalCount'] > 0
          htmlArray = []
          jointBodyItem = (item) =>
            if item['platform'] is "android"
              item['platform'] = "Android"
            else
              item['platform'] = "iOS"
            str = """
              <tr>
              <td>#{item['identifier']}</td>
              <td>#{item['platform']}</td>
              <td>#{item['name']}</td>
              <td>#{item['describe']}</td>
              <td>#{item['updateTime']}</td>
              <td><a value="#{item['id']}" text="#{item['name']}" class="engineSelectA">选择</a></td>
              </tr>
            """
            htmlArray.push(str)
          jointBodyItem item for item in data["data"]
          @engineItemShowView.html(htmlArray.join(""))
          @.find(".engineSelectA").on "click",(e) => @clickEngineSelectA(e)
        else
          @engineItemShowView.html("没有引擎...")
      error:(msg) =>
        console.log msg
    client.getEngineList params,@engineType,platform,pageIndex,pageSize
  # 初始化引擎列表
  initEngineTableView:() ->
    @pageIndex = 1
    @pageSize = 4
    @getApiEngingList @pageIndex,@pageSize


  # 点击选择，直接就获取引擎的版本列表
  clickEngineSelectA:(e) ->
    @step = 4
    @engineTableView.hide()
    @engineVersionView.show()

    #初始化分页信息
    @pageSize = 4
    @pageIndex = 1
    @pageTotal = 1
    el = e.currentTarget
    @engineId = $(el).attr("value")
    @enginName.html("&nbsp;&nbsp;"+$(el).attr("text"))
    console.log @engineId
    @getEngineVersionList(@pageIndex,@pageSize)

  # 根据引擎的Id 获取引擎版本列表并显示出来
  getEngineVersionList:(pageIndex,pageSize) ->
    params =
      sendCookie:true
      success:(data)=>
        # console.log data
        # 判断是否没有下一页了
        if data['totalCount'] <= pageIndex*@pageSize
          @.find(".engineVersionListClass.nextPageButton").attr("disabled",true)
        else
          @.find(".engineVersionListClass.nextPageButton").attr("disabled",false)
        if data["totalCount"] > 0
          htmlArray = []
          count = 0
          # @engineVersionList = data["data"]
          jointBodyItem = (item) =>
            str = """
            <tr>
            <td>#{item["version"]}</td>
            <td>#{item["fileSize"]}</td>
            <td>#{item["uploadTime"]}</td>
            <td>#{item["updateContent"]}</td>
            <td><a value="#{count}" class="selectEngineVersionA">选择</a></td>
            </tr>
            """
            count = count + 1
            htmlArray.push(str)
          jointBodyItem item for item in data["data"]
          @engineVersionItemView.html(htmlArray.join(""))
          # 点击选择引擎版本链接所触发的事件
          selectEngineVersionAClick = (e) =>
            @engineVersionView.hide()
            @engineBasicMessageView.show()
            el = e.currentTarget
            index = $(el).attr("value")
            @step = 5
            # console.log @engineVersionList[index]
            @initEngineBasicView(data["data"][index])
          @.find(".selectEngineVersionA").on "click",(e) => selectEngineVersionAClick(e)
        else
          @engineVersionItemView.html("没有任何版本...")
      error: (msg) =>
        console.log msg
    client.getEngineVersionList(params,@engineId,pageIndex,pageSize)

  # 获取引擎信息
  getBasicMessageView:() ->
    params =
      sendCookie:true
      success:(data) =>
        console.log data
        @initEngineBasicView(data)
      error: (msg) =>
        console.log msg
    client.getDefaultEngineMessage(params,@buildPlatform)

  # 初始化引擎基本信息
  initEngineBasicView:(data) ->
    @engineMessage = data
    if @buildPlatform is "iOS"
      @.find(".iOSSupportView").show()
    else
      @.find(".iOSSupportView").hide()
    if data["platform"] is "android"
      data["platform"] = "Android"
    else
      data["platform"] = "iOS"
    @engineIdView.html(data["identifier"])
    @engineName.html(data["name"])
    @platform.html(data["platform"])
    @engineSize.html(data["fileSize"])
    @engineVersion.html(data["version"])
    console.log "env=",data["buildEnvironment"]["name"]
    @buildEnv.html(data["buildEnvironment"]["name"]+data["buildEnvironment"]["version"])

  # 获取左边文件
  setSelectItem:(path) ->
    filePath = pathM.join path, @projectConfigFileName
    #判断文件是否存在，不存在则跳出
    if !fs.existsSync(filePath)
      return
    obj = Util.readJsonSync filePath
    if obj
      projectName = pathM.basename path
      optionStr = "<option value='#{path}'>#{projectName}  -  #{path}</option>"
      @selectProject.append optionStr

  # 选择应用下来框选择的选项发生改变时会被触发
  onSelectChange: (e) ->
    el = e.currentTarget
    if el.value == '其他'
      @open()

  # 当选择应用是点击了下拉框中的其他选项时触发
  open: ->
    atom.pickFolder (paths) =>
      if paths?
        path = pathM.join paths[0]
        # console.log  path
        filePath = pathM.join path,@projectConfigFileName
        if !fs.existsSync(filePath)
          @.find("select option:first").prop("selected","selected")
          alert @selectProjectTxt
          return
        # console.log filePath
        if !fs.existsSync(filePath)
          @.find("select option:first").prop("selected","selected")
          alert "请选择正确的应用"
          return
        obj = Util.readJsonSync filePath
        if obj
          projectName = pathM.basename path
          optionStr = "<option value='#{path}'>#{projectName}  -  #{path}</option>"
          @.find("select option[value=' ']").remove()
          @selectProject.prepend optionStr
        else
          alert desc.selectCorrectProject
        @selectProject.get(0).selectedIndex = 0
      else
        @selectProject.get(0).selectedIndex = 0

  #获取苹果手机横屏显示类型
  getIPhoneScrossHtml:() ->
    if @projectLastContent
      # console.log  @projectLastContent
      images = @projectLastContent["base"]["images"]
      """
      <li>
      <div class='iphone-scross-launch' >
      <img class='iphone-scross-launch-img' src='#{images["iphone960_640"]}' value='iphone960_640'>
      </div>
      <p>960&nbsp;X&nbsp;640</p>
      </li>&nbsp;
      <li>
      <div class='iphone-scross-launch'>
      <img class='iphone-scross-launch-img' src='#{images["iphone1136_640"]}' value='iphone1136_640'>
      </div>
      <p>1136&nbsp;X&nbsp;640</p>
      </li>&nbsp;
      <li>
      <div class='iphone-scross-launch'>
      <img class='iphone-scross-launch-img' src='#{images["iphone1334_750"]}' value='iphone1334_750'>
      </div>
      <p>1334&nbsp;X&nbsp;750</p>
      </li>&nbsp;
      <li>
      <div class='iphone-scross-launch'>
      <img class='iphone-scross-launch-img' src='#{images["iphone2208_1242"]}' value='iphone2208_1242'>
      </div>
      <p>2208&nbsp;X&nbsp;1242</p>
      </li>&nbsp;
      """
    else
      iphoneSrc = desc.getImgPath "default_app_iphone_scross_logo.png"
      """
      <li>
      <div class='iphone-scross-launch' >
      <img class='iphone-scross-launch-img' src='#{iphoneSrc}' value='iphone960_640'>
      </div>
      <p>960&nbsp;X&nbsp;640</p>
      </li>&nbsp;
      <li>
      <div class='iphone-scross-launch'>
      <img class='iphone-scross-launch-img' src='#{iphoneSrc}' value='iphone1136_640'>
      </div>
      <p>1136&nbsp;X&nbsp;640</p>
      </li>&nbsp;
      <li>
      <div class='iphone-scross-launch'>
      <img class='iphone-scross-launch-img' src='#{iphoneSrc}' value='iphone1334_750'>
      </div>
      <p>1334&nbsp;X&nbsp;750</p>
      </li>&nbsp;
      <li>
      <div class='iphone-scross-launch'>
      <img class='iphone-scross-launch-img' src='#{iphoneSrc}' value='iphone2208_1242'>
      </div>
      <p>2208&nbsp;X&nbsp;1242</p>
      </li>&nbsp;
      """

  # 获取苹果手机竖屏显示类型
  getIPhoneVerticalHtml:() ->
    if @projectLastContent
      # console.log  @projectLastContent
      images = @projectLastContent["base"]["images"]
      """
      <li>
      <div class='iphone-launch' >
      <img class='iphone-launch-img' src='#{images["iphone640_960"]}' value='iphone640_960'>
      </div>
      <p>640&nbsp;X&nbsp;960</p>
      </li>&nbsp;
      <li>
      <div class='iphone-launch'>
      <img class='iphone-launch-img' src='#{images["iphone640_960"]}' value='iphone640_1136'>
      </div>
      <p>640&nbsp;X&nbsp;1136</p>
      </li>&nbsp;
      <li>
      <div class='iphone-launch'>
      <img class='iphone-launch-img' src='#{images["iphone640_960"]}' value='iphone750_1334'>
      </div>
      <p>750&nbsp;X&nbsp;1334</p>
      </li>&nbsp;
      <li>
      <div class='iphone-launch'>
      <img class='iphone-launch-img' src='#{iphone1242_2208}' value='iphone1242_2208'>
      </div>
      <p>1242&nbsp;X&nbsp;2208</p>
      </li>&nbsp;
      """
    else
      iphoneSrc = desc.getImgPath "default_app_iphone_logo.png"
      """
      <li>
      <div class='iphone-launch' >
      <img class='iphone-launch-img' src='#{iphoneSrc}' value='iphone640_960'>
      </div>
      <p>640&nbsp;X&nbsp;960</p>
      </li>&nbsp;
      <li>
      <div class='iphone-launch'>
      <img class='iphone-launch-img' src='#{iphoneSrc}' value='iphone640_1136'>
      </div>
      <p>640&nbsp;X&nbsp;1136</p>
      </li>&nbsp;
      <li>
      <div class='iphone-launch'>
      <img class='iphone-launch-img' src='#{iphoneSrc}' value='iphone750_1334'>
      </div>
      <p>750&nbsp;X&nbsp;1334</p>
      </li>&nbsp;
      <li>
      <div class='iphone-launch'>
      <img class='iphone-launch-img' src='#{iphoneSrc}' value='iphone1242_2208'>
      </div>
      <p>1242&nbsp;X&nbsp;2208</p>
      </li>&nbsp;
      """

  #获取苹果平板横屏显示类型
  getIPadScrossHtml:() ->
    if @projectLastContent
      images = @projectLastContent["base"]["images"]
      """
      <li>
      <div class='ipad-scross-launch' >
      <img class='ipad-scross-launch-img' src='#{images["ipad2208_1242"]}' value='ipad2208_1242'>
      </div>
      <p>2208 X 1242</p>
      </li>&nbsp;
      """
    else
      ipadSrc = desc.getImgPath "default_app_ipad_scross_logo.png"
      """
      <li>
      <div class='ipad-scross-launch' >
      <img class='ipad-scross-launch-img' src='#{ipadSrc}' value='ipad2208_1242'>
      </div>
      <p>2208 X 1242</p>
      </li>&nbsp;
      """

  #获取苹果平板竖屏显示类型
  getIPadVerticalHtml:() ->
    if @projectLastContent
      images = @projectLastContent["base"]["images"]
      """
      <li>
      <div class='ipad-launch' >
      <img class='ipad-launch-img' src='#{images["ipad1242_2208"]}' value='ipad1242_2208'>
      </div>
      <p>1242 X 2208</p>
      </li>&nbsp;
      """
    else
      ipadSrc = desc.getImgPath "default_app_ipad_logo.png"
      """
      <li>
      <div class='ipad-launch' >
      <img class='ipad-launch-img' src='#{ipadSrc}' value='ipad1242_2208'>
      </div>
      <p>1242 X 2208</p>
      </li>&nbsp;
      """

  #获取安卓手机横屏显示类型
  getAndroidScrossHtml:() ->
    if @projectLastContent
      images = @projectLastContent["base"]["images"]
      """
      <li>
      <div class='android-scross-launch' >
      <img class='android-scross-launch-img' src='#{images["android960_640"]}' value='android960_640'>
      </div>
      <p>960 X 640</p>
      </li>&nbsp;
      <li>
      <div class='android-scross-launch' >
      <img class='android-scross-launch-img' src='#{images["android1136_640"]}' value='android1136_640'>
      </div>
      <p>1136 X 640</p>
      </li>&nbsp;
      """
    else
      androidSrc = desc.getImgPath "default_app_android_scross_logo.png"
      """
      <li>
      <div class='android-scross-launch' >
      <img class='android-scross-launch-img' src='#{androidSrc}' value='android960_640'>
      </div>
      <p>960 X 640</p>
      </li>&nbsp;
      <li>
      <div class='android-scross-launch' >
      <img class='android-scross-launch-img' src='#{androidSrc}' value='android1136_640'>
      </div>
      <p>1136 X 640</p>
      </li>&nbsp;
      """

  #获取安卓手机竖屏显示类型
  getAndroidVerticalHtml:() ->
    if @projectLastContent
      images = @projectLastContent["base"]["images"]
      """
      <li>
      <div class='android-launch' >
      <img class='android-launch-img' src='#{images["android640_960"]}' value='android640_960'>
      </div>
      <p>640 X 960</p>
      </li>&nbsp;
      <li>
      <div class='android-launch' >
      <img class='android-launch-img' src='#{images["android640_1136"]}' value='android640_1136'>
      </div>
      <p>640 X 1136</p>
      </li>&nbsp;
      """
    else
      androidSrc = desc.getImgPath "default_app_android_logo.png"
      """
      <li>
      <div class='android-launch' >
      <img class='android-launch-img' src='#{androidSrc}' value='android640_960'>
      </div>
      <p>640 X 960</p>
      </li>&nbsp;
      <li>
      <div class='android-launch' >
      <img class='android-launch-img' src='#{androidSrc}' value='android640_1136'>
      </div>
      <p>640 X 1136</p>
      </li>&nbsp;
      """

  # 获取图片的url
  getImageUrlMethod:(fileId, pixel) ->
    if !fileId
      return fileId
    if !pixel
      pixel = ''
    QINIU_URL = null
    HEX_RADIX = ['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f']
    QINIU_HTTP = 'http://7xl047.com2.z0.glb.qiniucdn.com/'
    WEB_CONTEXT = @httpType+'://bsl.foreveross.com/qdt-web-dev/images/'
    QINIU_HTTPS = 'https://dn-qdt-web.qbox.me/'
    if @httpType is 'http'
      QINIU_URL = QINIU_HTTP
    else if @httpType is 'https'
      QINIU_URL = QINIU_HTTPS
    else
      QINIU_URL = ''
    console.log "QINIU_URL = #{QINIU_URL}"
    if fileId.indexOf("qdt_icon_") is 0
      return  WEB_CONTEXT + fileId
    else
      start = fileId.toLowerCase().charAt(0)
      console.log "start = #{start}"
      index = 0
      returnUrl = null
      methodFor = (item) =>
        if start is HEX_RADIX[index]
          returnUrl = QINIU_URL + fileId + pixel
          return
        console.log "item = #{item} , index = #{index}"
        index = index + 1
      methodFor item for item in HEX_RADIX
      if returnUrl
        return returnUrl
      if fileId.indexOf(QINIU_URL) is 0
        return QINIU_URL + fileId.substring(QINIU_URL.length, fileId.length) + pixel
      else if fileId.indexOf(QINIU_URL) is 0
        return QINIU_URL + fileId.substring(QINIU_URL.length, fileId.length) + pixel
      return fileId

module.exports =
  class BuildProjectView extends ChameleonBox
    options :
      title: desc.buildProjectMainTitle
      subview: new BuildProjectInfoView()
    closeView: ->
      super()
