desc = require '../utils/text-description'
pathM = require 'path'
{Directory} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'
client = require '../utils/client'

module.exports =
class SyncProjectView extends View

  projectDetail: {}

  @content: (params) ->
    @div class: 'new-project', =>
      @h2 '请填写要创建的应用信息:'
      @div class: 'form-horizontal', =>
        @div class: 'form-group', =>
          @label '请输入应用标识', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'appId', new TextEditorView(mini: true)
        @div class: 'form-group', =>
          @label '请输入应用名称', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'appName', new TextEditorView(mini: true)
        @div class: 'form-group', =>
          @label '应用创建位置', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @div class:'textEditStyle', outlet: 'appPath'
            @span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'openFolder'
        @div class: 'col-sm-9 col-sm-offset-3', =>
          @div '该目录已存在', class: 'text-warning hide', outlet: 'errorMsg'

  initialize: ->
    @appId.getModel().onDidChange => @checkProjectName()
    @appName.getModel().onDidChange => @checkInput()
    # @appPath.getModel().onDidChange => @checkPath()

  attached: ->
    @type = @parentView.options.newType
    @getProjectDetail(@parentView.options.projectId, @parentView.options.account_id)
    @parentView.setNextBtn('finish')
    @parentView.disableNext()
    @appPath.setText desc.newProjectDefaultPath

  getProjectDetail: (projectId, accountId) ->
    params =
      sendCookie: true
      qs:
        account: accountId
        identifier: projectId
      success: (data) =>
        @projectDetail = data
        @appId.setText @projectDetail.identifier
        @appName.setText @projectDetail.name
      error: (err) ->
        console.log err
    client.getProjectDetail params

  openFolder: ->
    atom.pickFolder (paths) =>
      if paths?
        console.log paths[0]
        @appPath.html paths[0]

  getElement: ->
    @element

  getProjectInfo: ->
    appId = @appId.getText().trim()
    appPath = @appPath.html().trim()
    path = pathM.join appPath,appId
    dir = new Directory(path)
    path = pathM.join desc.newProjectDefaultPath,dir.getBaseName() if dir.getParent().isRoot() is yes
    projectInfo =
      appId : @appId.getText()
      appName : @appName.getText()
      appPath : path

    console.log projectInfo
    projectInfo

  checkInput: ->
    flag1 = @appId.getText().trim() isnt ""
    flag2 = @appName.getText().trim() isnt ""
    flag3 = @appPath.html().trim() isnt ""
    flag4 = @errorMsg.hasClass('hide')

    if flag1 and flag2 and flag3 and flag4
      @parentView.enableNext()
    else
      @parentView.disableNext()


  checkProjectName: ->
    str = @appId.getText().trim()
    console.log Util.checkProjectName str
    if Util.checkProjectName str
      @errorMsg2.addClass('hide')
    else
      @errorMsg2.removeClass('hide')
    @checkPath()

  checkPath: ->
    appId = @appId.getText().trim()
    appPath = @appPath.html().trim()
    path = pathM.join appPath,appId
    if path isnt ""
      dir = new Directory(path);
      dir.exists()
        .then (isExists) =>
          console.log isExists,dir.getRealPathSync()
          unless isExists
            @errorMsg.addClass('hide')

          else
            @errorMsg.removeClass('hide')
          @checkInput()

  nextStep:(box) ->
    box.setPrevStep @
    box.mergeOptions {projectInfo: @getProjectInfo(), projectDetail: @projectDetail, newType: 'syncProject'}
    box.nextStep()
