ChameleonBuilderView = null
{$} = require 'atom-space-pen-views'
ViewUri = 'atom://ChameleonBuilder'
util = require '../utils/util'
pathM = require 'path'
desc = require '../utils/text-description'
_ = require 'underscore-plus'

createView = (state) ->
  console.log state
  ChameleonBuilderView ?= require './builder-view'
  new ChameleonBuilderView(state)

deserializer =
  name: 'ChameleonBuilderView'
  deserialize: (state) ->
    createView(state)

atom.deserializers.add(deserializer)

module.exports =
  activate: (options)->
    console.log options

    @server = util.startServer()
    @appConfig = $.extend(true, options, {})
    console.log @appConfig

    ViewUri = "atom://#{options.moduleInfo.identifier}"
    atom.workspace.addOpener (filePath) =>
      console.log filePath, ViewUri
      @CreateView = createView({uri: ViewUri, appConfig: $.extend(true, @appConfig.builderConfig, {})}) if filePath is ViewUri

    atom.workspace.open(ViewUri)

    eventEmitter = util.eventEmitter().on 'getPort', (port)=>
      util.addEventtoList port, (e)=>
        builderConfig = JSON.parse e.data
        @appConfig.builderConfig = builderConfig
        if @appConfig.projectInfo?
          @createProject @appConfig
        else
          @createModule @appConfig
        eventEmitter.dispose()

  serialize: ->
    deserializer: @constructor.name
    uri: @getURI()

  createModule: (options) ->
    util.createModule options, (err) =>
      return console.error err if err?
      console.log 'success'
      console.log @server
      # @closeBuilder()

  createProject: (options) ->
    info = options.projectInfo
    util.createDir info.appPath, (err) =>
      if err
        console.error err
        alert "应用创建失败#{':权限不足' if err.code is 'EACCES'}"
      else
        appConfigPath = pathM.join info.appPath,desc.projectConfigFileName
        appConfig = util.formatAppConfigToObj(info)
        util.createModule options, (err) =>
          return console.error err if err?
          console.log 'success'
          moduleInfo = options.moduleInfo
          moduleId = moduleInfo.identifier
          appConfig.mainModule = moduleId
          appConfig.modules[moduleId] = desc.minVersion
          util.writeJson appConfigPath, appConfig, (err) =>
            throw err if err
            atom.workspace.open appConfigPath
            aft = =>
              util.rumAtomCommand('tree-view:reveal-active-file')
            _.debounce(aft,300)
          alert desc.createAppSuccess
          atom.project.addPath(info.appPath)
          util.rumAtomCommand 'tree-view:toggle' if $('.tree-view-resizer').length is 0
          @closeBuilder()

  closeBuilder: () ->
    util.stopServer(@server.server)