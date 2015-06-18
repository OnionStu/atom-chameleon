{$,Emitter} = require 'atom'
desc = require '../utils/text-description'
ChameleonBox = require '../utils/chameleon-box-view'
CreateProjectView = require './create-project-view'

module.exports = CreateProject =
  chameleonBox: null
  modalPanel: null

  activate: (state) ->
    opt =
      title : desc.createProject
      subview : new CreateProjectView()
      hideNextBtn :　true
      hidePrevBtn :　true

    @chameleonBox = new ChameleonBox(opt)
    @chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
    @chameleonBox.move()
    @chameleonBox.onCancelClick = => @closeView()
    @chameleonBox.onCloseClick = => @closeView()
    @chameleonBox.onNextClick = => @chameleonBox.contentView.nextStep()
    @chameleonBox.onPrevClick = => @chameleonBox.contentView.prevStep()

  deactivate: ->
    @modalPanel.destroy()
    @chameleonBox.destroy()

  serialize: ->
    chameleonBoxState: @chameleonBox.serialize()

  openView: ->
    unless @modalPanel.isVisible()
      console.log 'CreateProject was opened!'
      @modalPanel.show()

  closeView: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()

  createProject: ->
