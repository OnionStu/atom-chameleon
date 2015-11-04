{$, ScrollView} = require 'atom-space-pen-views'

Desc = require '../utils/text-description'
Util = require '../utils/util'
PathM = require 'path'

module.exports =
class RapidDevModeView extends ScrollView
  @content: ->
    @div class: 'chameleonsettingsview pane-item', tabindex: -1, =>
      @div class: 'settings-menu', =>
        @div '应用列表：', class: 'title'
        @ul outlet:'projectsList', =>
          @li class: 'settingsItem', outlet: 'other', =>
            @a Desc.other, class: 'icon icon-plus'
      @div class: 'settingsPanel',outlet: "settingsPanel", =>
        @div class: 'code-view', =>
          @div class: 'frameworkList', =>
            @header class: 'code-panel-header', =>
              @h2 '模块', =>
                @span class: 'icon icon-package'
              @button '添加', class: 'btn icon icon-plus addNewCode',click: 'addNewModule',outlet: 'addBtn'
            @ul outlet: 'codePackList', =>
              @li '', =>
                @h2 Desc.noModules

  getURI: -> @uri

  getTitle: -> Desc.rapidDevTitle

  initialize: ({@uri}) ->
    # super
    console.log @uri
    @projectInfos = {}

    @addProjectListItem path for path in @findProject()
    @addProjectListItem
    @on 'click', '.settingsItem', (e) =>
      @menuClick(e.currentTarget)

    @codePackList.on 'click', '.editModule', (e) =>
      @openBuilder(e)

  attached: ->
    console.log 'start'
    @toggleAddBtn()

  toggleAddBtn: ->
    if yes is $.isEmptyObject @projectInfos
      @addBtn.hide()
    else
      @addBtn.show()

  isProject: (path) ->
    configPath = PathM.join path,Desc.projectConfigFileName
    Util.isFileExist configPath,'sync'

  readConfig: (path,type) ->
    configFileName = if type is 'module' then Desc.moduleConfigFileName else Desc.projectConfigFileName
    configPath = PathM.join path,configFileName
    try
      config = Util.readJsonSync configPath
    catch err
      console.error err
      config = null
    return config

  checkProjectExistInList : (path) ->
    flag = false
    projectItems = document.getElementsByClassName('settingsItem');
    for el in projectItems
      flag = true if path is el.dataset.projectpath
    flag

  findProject: ->
    projects = []
    projectPaths = atom.project.getPaths()
    projectNum = projectPaths.length
    if projectNum isnt 0
      projectPaths.forEach (path,i) =>
        projects.push path if yes is @isProject path
    return projects

  addProjectListItem: (path) ->
    config = @readConfig path, 'project'
    if config?
      liStr = "<li class='settingsItem' data-projectpath='#{path}' data-id='#{config.identifier}'><a class='icon icon-file-submodule'>#{config.name}</a></li>"
      @projectInfos[config.identifier] = config
      @other.before liStr
      @toggleAddBtn()

  addModuleItem: (projectPath,modules) ->
    htmlStr = ''
    for module,version of modules
      modulePath = PathM.join projectPath,Desc.moduleLocatFileName,module
      moduleConfig = @readConfig modulePath, 'module'
      htmlStr += @getModuleItemHtmlStr moduleConfig if moduleConfig?
    htmlStr = "<li><h2>#{Desc.noModules}</h2></li>" if htmlStr is ''
    @codePackList.append htmlStr

  menuClick: (target) ->
    return @openFolder() if target is @other[0]
    return if target.classList.contains "active"
    activeItem = document.querySelector('.settingsItem.active')
    activeItem?.classList.remove('active')
    target.classList.add "active"
    projectPath = target.dataset.projectpath
    projectID = target.dataset.id
    config = @projectInfos[projectID]
    console.log projectPath
    @codePackList.empty()
    @addModuleItem projectPath,config.modules

  openFolder: ->
    console.log 'openFolder'
    atom.pickFolder (paths) =>
      if paths?
        path = paths[0]
        console.log "select path:#{path}"
        if @isProject path
          @addProjectListItem path if @checkProjectExistInList(path)  is no
        else
          alert Desc.selectCorrectProject

  addNewModule: ->
    activeItem = document.querySelector('.settingsItem.active')
    currentProject = activeItem.dataset.id
    @openBuilder(currentProject)

  openBuilder: (params) ->
    console.log "open builder",params

  getModuleItemHtmlStr: (module) ->
    return if !module?
    description = if module.releaseNote? then module.releaseNote else if module.description? then module.description else ''

    """

    <li class="codePack-card">
      <h2><a>#{module.name}</a></h2>
      <p>version: #{module.version}</p>
      <p>#{description}</p>
      <div class="btn-group">
        <button class="btn icon icon-pencil inline-block editModule" data-moduleid='#{module.identifier}'>#{Desc.edit}</button>
      </div>
    </li>

    """
