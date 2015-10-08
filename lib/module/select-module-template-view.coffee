Path = require 'path'
desc = require '../utils/text-description'
Util = require '../utils/util'
{$, TextEditorView, View} = require 'atom-space-pen-views'


module.exports =
class SelectModuleTmpView extends View

  frameworks: []

  @content: (params) ->
    @div class: 'create-module-type', =>
        @h2 '请选择模块模板:'
        @div class: 'flex-container', =>
          @button class:'btn btn-lg btn-action', outlet: 'prevPage',click: 'onPrevPageClick', =>
            @img src: desc.getImgPath 'arrow_left.png'
          @div class: 'frameList', outlet:'frameList'
          @button class:'btn btn-lg btn-action',outlet: 'nextPage',click: 'onNextPageClick', =>
            @img src: desc.getImgPath 'arrow_right.png'

  attached: ->
    @disableNextPage()
    @disablePrevPage()
    @pageIndex = 0;
    @pageSize = 1;
    @frameworks = []
    @findFrameworks()
    @addFrameworkItems()
    @parentView.setNextBtn('finish')
    @parentView.disableNext()

    $(document).on 'click','.new-item',(e) => @onItemClick(e)

  getElement: ->
    @element

  onItemClick: (e) ->
    el = e.currentTarget
    $('.new-item.select').removeClass 'select'
    el.classList.add 'select'
    @dataSource = el.dataset.name
    # @name = el.dataset.name
    @parentView.enableNext()

  onPrevPageClick: (e) ->
    @frameList.empty()
    @pageIndex--
    @disablePrevPage() if @pageIndex is 0
    @enableNextPage() if @nextPage.prop('disabled') is yes
    @addFrameworkItems()

  onNextPageClick: (e) ->
    @frameList.empty()
    @pageIndex++
    @disableNextPage() if @pageIndex is @pageSize-1
    @enablePrevPage() if @prevPage.prop('disabled') is yes
    @addFrameworkItems()

  nextStep:(box) ->
    box.setPrevStep @
    box.mergeOptions {source:@dataSource}
    box.nextStep()

  findFrameworks: ->
    @frameworks =  @parentView.options.frameworks
    @enableNextPage() if @nextPage.prop('disabled') is yes
    @pageSize = Math.ceil(@frameworks.length/3)

  addFrameworkItems: ->
    item1 = @frameworks[@pageIndex*3+0]
    item2 = @frameworks[@pageIndex*3+1]
    item3 = @frameworks[@pageIndex*3+2]
    @renderListItem item1 if item1?
    @renderListItem item2 if item2?
    @renderListItem item3 if item3?
    # $('.new-item').on 'click',(e) => @onItemClick(e)


  renderListItem: (data) ->
    data.icon?=desc.getImgPath 'icon_template.png'
    html = """
    <div class="new-item text-center" data-name="#{data.folderName}">
      <div class="itemIcon">
        <img src="#{data.icon}">
      </div>
      <h3 class="project-name">#{data.dataName}</h3>
    </div>
    """
    @frameList.append html


  enableNextPage: ->
    @nextPage.prop 'disabled',false

  disableNextPage: ->
    @nextPage.prop 'disabled',true

  enablePrevPage: ->
    @prevPage.prop 'disabled',false

  disablePrevPage: ->
    @prevPage.prop 'disabled',true