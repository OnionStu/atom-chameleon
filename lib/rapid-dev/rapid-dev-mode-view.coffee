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
      @div class: 'settingsPanel',outlet: "settingsPanel"

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

  attached: ->
    console.log 'start'

  isProject: (path) ->
    configPath = PathM.join path,Desc.ProjectConfigFileName
    Util.isFileExist configPath,'sync'

  readConfig: (path) ->
    configPath = PathM.join path,Desc.ProjectConfigFileName
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
    config = @readConfig path
    if config?
      liStr = "<li class='settingsItem' data-projectpath='#{path}' data-id='#{config.identifier}'><a class='icon icon-file-submodule'>#{config.name}</a></li>"
      # @projectsList.append liStr
      @projectInfos[config.identifier] = config
      @other.before liStr

  menuClick: (target) ->
    return @openFolder() if target is @other[0]
    return if target.classList.contains "active"
    activeItem = document.querySelector('.settingsItem.active')
    activeItem?.classList.remove('active')
    target.classList.add "active"
    projectPath = target.dataset.projectpath
    projectID = target.dataset.id
    console.log projectPath,@projectInfos[projectID]
    # configPath = PathM.join projectPath,Desc.ProjectConfigFileName
    # config = Util.readJsonSync configPath
    # config.modules

  openFolder: ->
    console.log 'openFolder'
    atom.pickFolder (paths) =>
      if paths?
        path = paths[0]
        console.log "select path:#{path}"
        if @isProject path
          @addProjectListItem path if @checkProjectExistInList is no
        else
          alert Desc.selectCorrectProject
