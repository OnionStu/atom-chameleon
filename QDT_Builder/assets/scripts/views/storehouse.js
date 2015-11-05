define([
  'jquery', 'underscore', 'backbone',
  'scripts/event-dispatcher'
], function(
  $, _, Backbone,
  dispatcher
) {
  return Backbone.View.extend({

    el: $('#components-panel .left-panel-list'),

    initialize: function(options) {
      this.options = options;
      this.listenTo(dispatcher, 'disDraggable', this.disDraggable);
      this.listenTo(dispatcher, 'enDraggable', this.enDraggable);
    },

    disDraggable: function(name) {
      var $e = this.$el.find('.component-item[data-name=' + name + ']');
      $e.addClass('cant-draggable').removeAttr('draggable');
    },

    enDraggable: function(name) {
      var $e = this.$el.find('.component-item[data-name=' + name + ']');
      $e.removeClass('cant-draggable').attr('draggable', true);
    },

    render: function() {
      if (!_.isUndefined(this.collection)) {
        _.each(this.collection.renderAll(), function(snippet) {
          this.$el.append(snippet);
        }.bind(this));
      } else if (this.options.content){
        this.$el.append(this.options.content);
      }
      return this.$el[0];
    }
  })
})