{$, ScrollView} = require 'atom-space-pen-views'

desc = require '../utils/text-description'
util = require '../utils/util'

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


