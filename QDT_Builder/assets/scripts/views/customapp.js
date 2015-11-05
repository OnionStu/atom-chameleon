/* Todo: 
 *  1. 因为需要兼容 sui 的开发模式，不得不创建这个 className 为 page-content 的 view，感觉处理过程十分不合理，
 *     应有较大的优化空间。
 *  2.（理由同上），在处理页面中只能唯一存在的 component 的方法不合理，且只处理了 header 一种情况，方法扩展性不足。
*/

define([
  'jquery', 'underscore', 'backbone',
  'models/component',
  'scripts/event-dispatcher',
  'views/popover'
], function(
  $, _, Backbone,
  ComponentModel,
  dispatcher,
  popoverView
) {
  return Backbone.View.extend({

    tagName: 'div',

    className: 'page-content',

    events: {
      'dragover': 'dragoverHandler',
      'dragleave': 'dragleaveHandler',
      'drop': 'dropHandler',
      'click .component': 'clickHandler'
    },

    initialize: function(options) {
      this.$el.append('<div class="content">');
      this.options = options;
      console.log(this.collection);
      this.$SettingContainer = $('#component-setting');

      this.listenTo(dispatcher, 'dragstart', this.dragstartHandler);
      this.listenTo(dispatcher, 'dragend', this.dragendHandler);
      this.listenTo(dispatcher, 'deleteModel', this.deleteModel);
      this.listenTo(dispatcher, 'hideSettingPanel', this.removePopover);

      this.listenTo(this.collection, 'add', this.render);
      this.listenTo(this.collection, 'reset', this.render);
      this.listenTo(this.collection, 'remove', this.render);
      this.listenTo(this.collection, 'change', this.render);
    },

    render: function() {
      this.$el.find('.component').remove();
      this.$el.find('.line').remove();
      this.options.$body.find('.component-script').remove();
      if (!_.isUndefined(this.collection)){
        var $content = this.$el.find('.content');
        _.each(this.collection.renderAll(), function(component) {

          if(component.data('isfixed') === 'top'){
            component.insertBefore($content);
          } else {
            $content.append(component)
          }
        }.bind(this))
        var renderedTopComponent = this.collection.findWhere({fixed: 'top'});
        if (renderedTopComponent) {
          dispatcher.trigger('disDraggable', renderedTopComponent.get('title'))
        } else {
          dispatcher.trigger('enDraggable', 'header')
        }
      }

      return this.$el;
    },

    dragstartHandler: function(componentModel) {
      var index = 0;
      this.$components = this.$el.find('.content').children('.component');
      this.renderedComponent = [];
      this.currentComponent = componentModel;
      _.each(this.$components, function(renderedComponent) {
        var $renderedComponent = $(renderedComponent);
        this.renderedComponent.push({
          index: index++,
          top: $renderedComponent.position().top + this.$el.find('.content').position().top,
          height: $renderedComponent.height(),
          isfixed: $renderedComponent.data('isfixed')
        });
        if (!$renderedComponent.data('isfixed')){
          $(renderedComponent).before($('<div class="line"></div>'));  
        }
      }.bind(this))
      
      this.$el.append($('<div class="line"></div>'));
      this.$line = this.$el.find('.line');
      this.removePopover()
    },

    dragendHandler: function() {
      this.$el.find('.line').remove()
    },

    dropHandler: function(e) {
      // var componentType = e.originalEvent.dataTransfer.getData("Text");
      var index = this.hoverElementIndex > -1 ? this.hoverElementIndex : this.$line.length > 0 ? this.$line.length-1 : 0;
      if (this.currentComponent.get('fresh')) {
        //model是新添加的，则 add 进 collection
        var modelCopy = new ComponentModel($.extend(true, {}, this.currentComponent.attributes));
        if (this.currentComponent.get('fixed') === 'top') {
          index = 0;
        }
        if (this.collection.length > 0 && this.collection.models[0].attributes.fixed === 'top') {
          index += 1;
        }
        console.log('drop add')
        this.collection.add(modelCopy, {at: index});
        if (this.currentComponent.get('unique')){
          dispatcher.trigger('disDraggable', this.currentComponent.get('title'))
        }
      } else {
        //model不是新添加的，则属于已有 model 重新排序操作，reset collection
        var filterCollections = [],
                  collections = this.collection.toArray(),
                   firstModel;

        _.each(collections, function(collection) {
          if (collection.attributes.fixed !== 'top')
            var firstModel = collections[0];
          filterCollections.push(collection);
        });
        var currentIndex = _.indexOf(filterCollections, this.currentComponent);
        filterCollections.splice(index, 0, this.currentComponent);
        if (index !== currentIndex && index !== currentIndex + 1){
          var placeIndex = index > currentIndex ? currentIndex : currentIndex + 1;
          filterCollections.splice(placeIndex, 1);
          if (firstModel) {
            filterCollections.unshift(firstModel);
          }
          this.collection.reset(filterCollections);
        }
      }
    },

    dragoverHandler: function(e) {
      e.preventDefault();
      var topelement = _.find(this.renderedComponent, function(a) {
        if ((a.top + a.height + 21) > e.originalEvent.pageY) {
          return true
        } else {
          return false;
        }
      }.bind(this));
      if (this.currentComponent.get('fixed') === 'top') {
        if (this.$line[0].className !== 'line target') {
          this.$line[0].className = 'line target';
        }
      } else {
        if (!_.isUndefined(topelement)) {
          this.hoverElementIndex = topelement.index;
            if (this.$line[this.hoverElementIndex].className !== 'line target') {
              this.$line[this.hoverElementIndex].className = 'line target';
            }
        } else {
          var lineLength = this.$line.length;
          this.hoverElementIndex = -1;
          if (this.$line[lineLength-1].className !== 'line target') {
            this.$line[lineLength-1].className = 'line target';
          }
        }        
      }
      this.currentEle = this.hoverElementIndex;
      console.log(this.currentEle)
    },

    dragleaveHandler: function() {
      _.each(this.$line, function(line){
        line.className = 'line'
      })
    },

    clickHandler: function(e) {
      var currentCid     = e.currentTarget.dataset.cid,
          $currentTarget = $(e.currentTarget),
          currentModel   = _.find(this.collection.models, {cid: currentCid});
      if(this.popoverview)
        this.removePopover();

      this.popoverview = new popoverView({model: currentModel, parentView: this});
      $currentTarget.addClass('active');
      this.$SettingContainer.append(this.popoverview.render()).show();
      
    },

    removePopover: function() {
      if (this.popoverview) {
        this.$el.find('.component.active').removeClass('active');
        this.popoverview.remove();
        this.popoverview = null;
        this.$SettingContainer.hide();
      }
    },

    deleteModel: function(model) {
      if (model.get('unique')){
        dispatcher.trigger('enDraggable', model.get('title'))
      }
      this.collection.remove(model);
      this.removePopover();
    }
  })
})