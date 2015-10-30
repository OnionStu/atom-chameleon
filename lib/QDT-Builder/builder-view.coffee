{$, ScrollView} = require 'atom-space-pen-views'

desc = require '../utils/text-description'

module.exports =
class ChameleonBuilderView extends ScrollView
  @content: ->
    @iframe class: 'builder-iframe', src: 'http://localhost:9001'

  getURI: -> @uri

  getTitle: -> desc.builderPanelTitle

  initialize: ({@uri}) ->
    # super
    # @accountPanel = new AccountPanel()
    # @settingsPanel.html @accountPanel
    # @accountPanel = null
    # @on 'click', '.settingsItem', (e) =>
    #   @menuClick(e.currentTarget)
