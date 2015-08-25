desc = require '../utils/text-description'
{$, View} = require 'atom-space-pen-views'
Util = require '../utils/util'
client = require '../utils/client'
loadingMask = require '../utils/loadingMask'

syncInfoView = require './sync-project-info'

module.exports =
class SyncProjectView extends View
  LoadingMask: loadingMask
  @content: ->
    @div class: 'sync-project container', =>
      @div class: 'row', =>
        @div class: 'col-md-12', =>
          @h2 '导入应用'
          # @ul class: 'projectList', outlet: 'projectList'
          @div class: 'flex-container', =>
            @button class:'btn btn-lg btn-action', outlet: 'prevPage', click: 'onPrevPageClick', disabled: true, =>
              @img src: desc.getImgPath 'arrow_left.png'
            @div class: 'frameList', outlet:'projectList'
            @button class:'btn btn-lg btn-action',outlet: 'nextPage', click: 'onNextPageClick', disabled: true, =>
              @img src: desc.getImgPath 'arrow_right.png'

  pageSize: 3
  pageIndex: 1
  account_id: ''
  projects: []
  currentIndex: 1
  totalCount: 0

  getElement: ->
    @element

  attached: ->
    @parentView.disableNext()
    # console.log @nextPage
    if Util.isLogin()
      LoadingMask = new @LoadingMask()
      @parentView.setNextBtn()
      @parentView.setPrevBtn('back')
      @account_id = Util.store('chameleon').mail

      if @projects.length is 0
        @getProjectList 1, (data)=>
          @projects = @projects.concat(data.data)
          # console.log @projects
          @totalCount = data.totalCount
          @renderCurrentList()
      # params =
      #   qs:
      #     account: @account_id
      #     pageSize: @pageSize
      #     page: @page
      #   sendCookie: true
      #   success: (data) =>
      #     dataLength = data.length
      #     if dataLength > 0
      #       @projects = data.slice()
      #       @canClick()
      #       data.forEach (item)=>
      #         console.log item
      #         projectItem = new ProjectItem(item)
      #         @projectList.append projectItem
      #       $('.sync-item').on 'click', (e) => @onItemClick(e)
      #     else
      #       projectItem = new notProjectItem()
      #       @projectList.append projectItem
      #     @.children(".loading-mask").remove()
      #   error: (err) =>
      #     alert err

      # @.append(LoadingMask)
      # client.getUserProjects params

  canClick: () =>
    pageNum = Math.ceil(@totalCount/3)
    if @currentIndex < pageNum
      @enableClick('nextPage')
    else
      @disabledClick('nextPage')

    if @currentIndex > 1
      @enableClick('prevPage')
    else
      @disabledClick('prevPage')

  enableClick: (direction) ->
    dom = if direction is 'prevPage' then @prevPage else @nextPage
    dom.removeAttr('disabled')

  disabledClick: (direction) ->
    dom = if direction is 'prevPage' then @prevPage else @nextPage
    dom.attr('disabled', true)

  getProjectList: (pageIndex, cb) ->
    pageIndex = if typeof pageIndex isnt 'undefined' then pageIndex else 1
    params =
      qs:
        account: @account_id
        pageSize: 3
        page: pageIndex
      sendCookie: true
      success: cb
      error: (err) =>
        alert err

    client.getUserProjects params

  onNextPageClick: () ->
    @currentIndex++
    if @projects.length < @totalCount
      @getProjectList @currentIndex, (data)=>
        @projects = @projects.concat(data.data)
        console.log @projects
        @renderCurrentList()
    else
      @renderCurrentList()
    

  onPrevPageClick: () ->
    @currentIndex--
    @renderCurrentList()

  renderCurrentList: () ->
    console.log @currentIndex
    currentList = @projects.slice(@currentIndex * 3 - 3, @currentIndex * 3 )
    @projectList.html('')
    console.log currentList
    if currentList.length > 0
      currentList.forEach (item)=>
        projectItem = new ProjectItem(item)
        @projectList.append projectItem
      $('.new-item').on 'click', (e) => @onItemClick(e)
    @canClick()

  nextStep: (box)=>
    projectId = $('.select').attr('projectId')
    nextStepView = new syncInfoView(projectId)
    box.setPrevStep @
    box.mergeOptions {subview:nextStepView, projectId: projectId, account_id: @account_id}
    box.nextStep()

  onItemClick: (e) ->
    el = e.currentTarget
    console.log el
    $('.new-item.select').removeClass 'select'
    el.classList.add 'select'
    @createType = el.dataset.type
    @parentView.enableNext()


class ProjectItem extends View
  @content: (data) ->
    @div class: 'new-item text-center', projectId: data.identifier,  =>
      @div class: 'itemIcon', =>
        @img src: desc.getImgPath 'icon.png'
      @h3 data.name, class: 'project-name'

class notProjectItem extends View
  @content: ->
    @li class: 'sync-item inline-block new-item text-center',  =>
      @div class: 'add-icon icon icon-octoface'
      @h3 '暂无应用', class: 'project-name'
