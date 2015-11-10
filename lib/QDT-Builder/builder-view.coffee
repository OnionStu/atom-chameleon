{$, ScrollView} = require 'atom-space-pen-views'
pathM = require 'path'
desc = require '../utils/text-description'
util = require '../utils/util'
_ = require 'underscore-plus'

module.exports =
class ChameleonBuilderView extends ScrollView
  @content: ->
    @iframe class: 'builder-iframe'

  getURI: -> @uri

  getTitle: ->
    @uri.replace('atom://', '')

  initialize: (options) ->
    @uri = options.uri
    @appConfig = options.appConfig
    @eventEmitter = util.eventEmitter()

  attached: ->

    frames = window.frames
    eventEmitter = util.eventEmitter().on 'server_on', (e)=>
      console.log e
      console.log @appConfig
      @.attr {'src': e}
       .on 'load', ()=>
        _.each frames, (frame)=>
          if frame.location.href is e + '/'
            frame.postMessage JSON.stringify(@appConfig), e
        eventEmitter.dispose()

    

  
