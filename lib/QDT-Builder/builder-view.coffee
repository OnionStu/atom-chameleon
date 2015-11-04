{$, ScrollView} = require 'atom-space-pen-views'

desc = require '../utils/text-description'
util = require '../utils/util'

module.exports =
class ChameleonBuilderView extends ScrollView
  @content: ->
    @iframe outlet: 'iframeContainer', class: 'builder-iframe', src: ''

  getURI: -> @uri

  getTitle: -> desc.builderPanelTitle

  initialize: ({@uri}) ->
    # super
    # @accountPanel = new AccountPanel()
    # @settingsPanel.html @accountPanel
    # @accountPanel = null
    # @on 'click', '.settingsItem', (e) =>
    #   @menuClick(e.currentTarget)

  attached: ->
    util.eventEmitter().on 'server_on', (e)=>
      @.attr('src', e)

