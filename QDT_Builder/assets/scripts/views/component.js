define([
  'jquery', 'underscore', 'backbone',
  'scripts/event-dispatcher'
], function(
  $, _, Backbone,
  dispatcher
){
  return Backbone.View.extend({
    tagName: 'div',
    className: 'component',
    events: {
      'dragstart': 'dragstartHandler',
      'dragend': 'dragendHandler',
      // 'drag': 'dargHandler'
    },

    dragstartHandler: function(e) {
      dispatcher.trigger('dragstart', this.model)
      e.originalEvent.dataTransfer.setData("Text", e.target.dataset.name);
    },

    dragendHandler: function(e) {
      dispatcher.trigger('dragend', 'dragend')
    },

    dargHandler: function(e) {
      console.log(e)
    }
  })
})