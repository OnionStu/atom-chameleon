_ = require 'underscore-plus'
desc = require '../utils/text-description'
infoView = require './new-project-info'
{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class NewProjectView extends View

  @content: (params) ->
    @div class: 'new-project', =>
      @div class: 'step active', 'data-step': '1', =>
        @h2 '请选择要创建的项目类型:'
        @div class: 'new-item text-center', 'data-type': 'empty',  =>
          @img class: 'pic', src:desc.iconPath
          @h3 '空白项目',class: 'project-name'
        @div class: 'new-item text-center', 'data-type': 'frame', =>
          @img class: 'pic', src: desc.iconPath
          @h3 '自带框架项目',class: 'project-name'
        @div class: 'new-item text-center', 'data-type': 'template',  =>
          @img class: 'pic', src: desc.iconPath
          @h3 '业务模板',class: 'project-name'

  attached: ->
    @parentView.setPrevBtn('back')
    @parentView.disableNext()
    $('.new-item').on 'click',(e) => @onItemClick(e)

  getElement: ->
    @element

  onItemClick: (e) ->
    el = e.currentTarget
    $('.new-item.select').removeClass 'select'
    el.classList.add 'select'
    @newType = el.dataset.type
    if @newType is 'template'
      @parentView.disableNext()
    else
      @parentView.enableNext()

  nextStep:(box) ->
    nextStepView = new infoView()
    box.setPrevStep @
    box.mergeOptions {subview:nextStepView,newType:@newType}
    box.nextStep()