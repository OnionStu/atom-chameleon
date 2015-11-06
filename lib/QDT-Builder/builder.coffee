ChameleonBuilderView = null

ViewUri = 'atom://ChameleonBuilder'
util = require '../utils/util'

createView = (state) ->
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
    ViewUri = "atom://#{options.moduleInfo.identifier}"
    atom.workspace.addOpener (filePath) ->
      createView({uri: ViewUri, appConfig: options}) if filePath is ViewUri

    atom.workspace.open(ViewUri)
    util.startServer()

  serialize: ->
    deserializer: @constructor.name
    uri: @getURI()