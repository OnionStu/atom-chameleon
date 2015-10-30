ChameleonBuilderView = null

ViewUri = 'atom://ChameleonBuilder'

createView = (state) ->
  ChameleonBuilderView ?= require './builder-view'
  new ChameleonBuilderView(state)

deserializer =
  name: 'ChameleonBuilderView'
  deserialize: (state) ->
    createView(state)

atom.deserializers.add(deserializer)

module.exports =
  activate: ->
    atom.workspace.addOpener (filePath) ->
      createView(uri: ViewUri) if filePath is ViewUri

    atom.workspace.open(ViewUri)

  serialize: ->
    deserializer: @constructor.name
    uri: @getURI()