CreateProject = require './project/create-project'
Login = require './login/login'
ConfigureModule = require './configure/module/module'
ConfigureApp = require './configure/application/app'
ConfigureGlobal = require './configure/global/global'
Settings = require './settings/settings'
{CompositeDisposable} = require 'atom'

ChemaleonSettings = require './settings/settings'

module.exports = Chameleon =
  createProject: null
  login: null
  configureModule: null
  configureApp: null
  subscriptions: null
  configureGlobal: null
  workspace: atom.workspace

  activate: (state) ->
    # console.log CreateProject,Login
    @createProject = CreateProject
    @createProject.activate(state)
    @login = Login
    # @login.activate(state)
    @configureModule = ConfigureModule
    # @configureModule.activate(state)
    @configureApp = ConfigureApp
    # @configureApp.activate(state)
    @configureGlobal = ConfigureGlobal
    # @configureGlobal.activate(state)
    # @login = Login
    # @login.activate(state)

    # @settings = Settings


    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:settings': => @settings()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:create-project': => @createProject.openView()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:login': => @loginViewOpen(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:configure:module': => @configureModuleViewOpen(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:configure:application': => @configureAppViewOpen(state)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chameleon:configure:global' : => @configureGlobalViewOpen(state)

  deactivate: ->
    @subscriptions.dispose()
    @createProject.destroy()
    @login.destroy()

  settings: ->
    ChemaleonSettings.activate()

  serialize: ->
    @createProject.serialize()
    @login.serialize()

    # @login.toggle()
  loginViewOpen:(state) ->
    @login.activate(state)
    @login.openView()

  configureModuleViewOpen:(state) ->
    @configureModule.activate(state)
    @configureModule.openView()

  configureAppViewOpen:(state) ->
    @configureApp.activate(state)
    @configureApp.openView()

  configureGlobalViewOpen:(state) ->
    @configureGlobal.activate(state)
    @configureGlobal.openView()



  # createProject: ->
  #   console.log 'create-project'
  #   unless @createProjectView.modalPanel.isVisible()
  #     @createProjectView.modalPanel.show()
