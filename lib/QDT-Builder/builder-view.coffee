{$, ScrollView} = require 'atom-space-pen-views'
pathM = require 'path'
desc = require '../utils/text-description'
util = require '../utils/util'
_ = require 'underscore-plus'

module.exports =
class ChameleonBuilderView extends ScrollView
  @content: ->
    @iframe outlet: 'iframeContainer', class: 'builder-iframe', src: ''

  getURI: -> @uri

  getTitle: ->
    @uri.replace('atom://', '')

  initialize: (options) ->
    @uri = options.uri
    @appConfig = options.appConfig

  attached: ->
    util.eventEmitter().on 'server_on', (e)=>
      @.attr 'src', e
       .on 'load', ()=>
        window.frames[0].postMessage JSON.stringify(@appConfig), e

    getBuilderConfig = (e) =>
      builderConfig = JSON.parse e.data
      @appConfig.builderConfig = builderConfig
      console.log @appConfig
      if @appConfig.projectInfo?
        @createProject @appConfig
      else
        @createModule @appConfig
      window.removeEventListener 'message', getBuilderConfig, false

    window.addEventListener 'message', getBuilderConfig, false

  createModule: (options) ->
    util.createModule options, (err) =>
      return console.error err if err?
      console.log 'success'

  createProject: (options) ->
    info = options.projectInfo
    Util.createDir info.appPath, (err) =>
      if err
        console.error err
        alert "应用创建失败#{':权限不足' if err.code is 'EACCES'}"
      else
        appConfigPath = pathM.join info.appPath,desc.projectConfigFileName
        appConfig = Util.formatAppConfigToObj(info)
        util.createModule options, (err) =>
          return console.error err if err?
          console.log 'success'
          moduleInfo = options.moduleInfo
          moduleId = moduleInfo.identifier
          appConfig.mainModule = moduleId
          appConfig.modules[moduleId] = desc.minVersion
          Util.writeJson appConfigPath, appConfig, (err) =>
            throw err if err
            atom.workspace.open appConfigPath
            aft = =>
              Util.rumAtomCommand('tree-view:reveal-active-file')
            _.debounce(aft,300)
          alert desc.createAppSuccess
          atom.project.addPath(info.appPath)
          Util.rumAtomCommand 'tree-view:toggle' if $('.tree-view-resizer').length is 0
