desc = require '../utils/text-description'
Util = require '../utils/util'
pathM = require 'path'
{Directory} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'
CreateModuleTypeView = require './create-module-type-view'

module.exports =
class CreateModuleInfoView extends View

  @content: ->
    @div class: 'create-module', =>
      @h2 desc.createModuleTitle, class: 'box-subtitle'
      @div class: 'box-form', =>
        @div class: 'form-row clearfix', =>
          @label desc.moduleInApp, class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @select class: 'form-control', outlet: 'selectProject'
        @div class: 'form-row clearfix', =>
          @label desc.modulePath, class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @div class: 'textEditStyle', outlet: 'modulePath'
            @span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'openFolder'
        @div class: 'form-row clearfix', =>
          @label desc.moduleId, class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @subview 'moduleId', new TextEditorView(mini: true)
        @div class: 'form-row msg clearfix in-row', =>
          @div desc.moduleIdErrorMsg, class: 'text-warning hide errorMsg', outlet: 'errorMsg2'
        @div class: 'form-row clearfix', =>
          @label desc.moduleName, class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @subview 'moduleName', new TextEditorView(mini: true)
        @div class: 'form-row msg clearfix', =>
          @div desc.createModuleErrorMsg, class: 'text-warning hide errorMsg', outlet: 'errorMsg'

  initialize: ->

  attached: ->
    # @modulePath.getModel().onDidChange => @checkPath()
    @moduleId.getModel().onDidChange => @checkPath()
    @moduleName.getModel().onDidChange => @checkInput()
    # @mainEntry.getModel().onDidChange => @checkInput()
    @selectProject.on 'change',(e) => @onSelectChange(e)
    @moduleName.setText ''
    @moduleId.setText ''
    # @mainEntry.setText desc.mainEntryFileName
    @modulePath.html desc.newProjectDefaultPath

    # @parentView.setNextBtn('finish')
    @parentView.disableNext()
    @parentView.hidePrevBtn()

    projects = @findProject()
    projectNum = projects.length
    if projectNum isnt 0
      @selectProject.empty()
      @setSelectItem path for path in projects
      @modulePath.parents('.form-row').addClass 'hide'
      @selectProject.parents('.form-row').removeClass 'hide'
      @modulePath.html pathM.join @selectProject.val(),'modules'
    else
      @selectProject.parents('.form-row').addClass 'hide'
      @modulePath.parents('.form-row').removeClass 'hide'
    # console.log @
    @checkPath()

  # destroy: ->
  #   @element.remove()
  setSelectItem:(path) ->
    filePath = pathM.join path,desc.ProjectConfigFileName
    obj = Util.readJsonSync filePath
    projectName = if obj? then obj.name else pathM.basename path
    optionStr = "<option value='#{path}'>#{projectName}  -  #{path}</option>"
    @selectProject.append optionStr

  getElement: ->
    @element

  serialize: ->

  findProject: ->
    projects = []
    projectPaths = atom.project.getPaths()
    projectNum = projectPaths.length
    if projectNum isnt 0
      projectPaths.forEach (path,i) ->
        configPath = pathM.join path,desc.ProjectConfigFileName
        projects.push path if yes is Util.isFileExist configPath,'sync'
    return projects

  getModuleInfo: ->
    modulePath = @modulePath.html()
    if @modulePath.isProject
      modulePath = pathM.join modulePath,'modules'
      isProject = true
    else
      isProject = false

    info =
      mainEntry: desc.mainEntryFileName
      moduleId: @moduleId.getText()
      moduleName: @moduleName.getText()
      modulePath: modulePath
      isChameleonProject:isProject
    info

  openFolder: (e) ->
    console.log 'openFolder'
    atom.pickFolder (paths) =>
      if paths?
        console.log "select path:#{paths[0]}"
        @modulePath.html paths[0]

  onSelectChange: (e) ->
    el = e.currentTarget
    # console.log el.value
    @modulePath.html el.value
    @checkPath()

  checkPath: ->
    path = @moduleId.getText().trim()
    if path isnt ""
      regEx = /^[a-zA-z]\w{5,31}$/
      if regEx.test path
        @errorMsg2.addClass('hide')
      else
        @errorMsg2.removeClass('hide')
      projectPath = @modulePath.html().trim()

      configPath = pathM.join projectPath,desc.ProjectConfigFileName
      isProject = @modulePath.isProject = Util.isFileExist configPath,'sync'
      projectPath = pathM.join projectPath,'modules' if isProject


      path = pathM.join projectPath,path
      console.log path
      dir = new Directory(path);
      dir.exists()
        .then (isExists) =>
          console.log isExists,@errorMsg
          unless isExists
            @errorMsg.addClass('hide')
          else
            @errorMsg.removeClass('hide')
          @checkInput()


  checkInput: ->
    flag1 = @moduleId.getText().trim() isnt ""
    flag2 = @moduleName.getText().trim() isnt ""
    # flag3 = @mainEntry.getText().trim() isnt ""
    flag4 = @modulePath.html().trim() isnt ""
    flag5 = @errorMsg.hasClass 'hide'
    flag6 = @errorMsg2.hasClass 'hide'

    if flag1 and flag2 and flag4 and flag5 and flag6
      @parentView.enableNext()
    else
      @parentView.disableNext()

  nextStep: (box)->
    box.setPrevStep @
    box.mergeOptions {moduleInfo:@getModuleInfo(),subview:CreateModuleTypeView}
    box.nextStep()
