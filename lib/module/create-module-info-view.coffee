desc = require '../utils/text-description'
Util = require '../utils/util'
pathM = require 'path'
{Directory} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class CreateModuleInfoView extends View

  @content: ->
    @div class: 'create-module', =>
      @h2 desc.CreateModuleTitle, class: 'box-subtitle'
      @div class: 'box-form', =>
        @div class: 'form-row clearfix', =>
          @label '模块所在应用', class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @select class: 'form-control', outlet: 'selectProject'
        @div class: 'form-row clearfix', =>
          @label desc.modulePath, class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @subview 'modulePath', new TextEditorView(mini: true)
            @span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'openFolder'
        @div class: 'form-row clearfix', =>
          @label desc.moduleId, class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @subview 'moduleId', new TextEditorView(mini: true)
        @div class: 'form-row clearfix', =>
          @label desc.moduleName, class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @subview 'moduleName', new TextEditorView(mini: true)
        @div class: 'form-row msg clearfix hide', =>
          @div desc.createModuleErrorMsg, class: 'text-warning', outlet: 'errorMsg'

  initialize: ->
    # @modulePath.getModel().onDidChange => @checkPath()
    # @moduleId.getModel().onDidChange => @checkPath()
    # @moduleName.getModel().onDidChange => @checkInput()
    # @mainEntry.getModel().onDidChange => @checkInput()
    # @selectProject.on 'change',(e) => @onSelectChange(e)

  attached: ->
    @modulePath.getModel().onDidChange => @checkPath()
    @moduleId.getModel().onDidChange => @checkPath()
    @moduleName.getModel().onDidChange => @checkInput()
    # @mainEntry.getModel().onDidChange => @checkInput()
    @selectProject.on 'change',(e) => @onSelectChange(e)
    @moduleName.setText ''
    @moduleId.setText ''
    # @mainEntry.setText desc.mainEntryFileName
    @modulePath.setText desc.newProjectDefaultPath

    @parentView.setNextBtn('finish')
    @parentView.disableNext()
    @parentView.hidePrevBtn()

    projectPaths = atom.project.getPaths()
    projectNum = projectPaths.length
    if projectNum isnt 0
      @selectProject.empty()
      @setSelectItem path for path in projectPaths
      @modulePath.parents('.form-row').addClass 'hide'
      @selectProject.parents('.form-row').removeClass 'hide'
      @modulePath.setText pathM.join @selectProject.val(),'modules'
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

  getModuleInfo: ->
    modulePath = @modulePath.getText()
    hasModulesFolder = modulePath.lastIndexOf('modules') isnt '-1'
    if hasModulesFolder
      projectHome = pathM.dirname modulePath
    else
      projectHome = modulePath
    configPath = pathM.join projectHome,desc.ProjectConfigFileName
    isProject = Util.isFileExist configPath,'sync'

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
        console.log paths[0]
        @modulePath.setText paths[0]

  onSelectChange: (e) ->
    el = e.currentTarget
    # console.log el.value
    @modulePath.setText pathM.join el.value,'modules'

  checkPath: ->
    path = @moduleId.getText().trim()
    if path isnt ""
      projectPath = @modulePath.getText().trim()
      path = pathM.join projectPath,path
      dir = new Directory(path);
      dir.exists()
        .then (isExists) =>
          unless isExists
            @errorMsg.addClass('hide')
          else
            @errorMsg.removeClass('hide')
          @checkInput()


  checkInput: ->
    flag1 = @moduleId.getText().trim() isnt ""
    flag2 = @moduleName.getText().trim() isnt ""
    # flag3 = @mainEntry.getText().trim() isnt ""
    flag4 = @modulePath.getText().trim() isnt ""
    flag5 = @errorMsg.hasClass 'hide'

    if flag1 and flag2 and flag4 and flag5
      @parentView.enableNext()
    else
      @parentView.disableNext()

  nextStep: (box)->
    box.setPrevStep @
    box.mergeOptions {moduleInfo:@getModuleInfo()}
    box.nextStep()
