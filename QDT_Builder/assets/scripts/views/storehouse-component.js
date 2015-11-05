define([
  'jquery', 'underscore', 'backbone',
  'views/component',
  'text!templates/storehouse/component.html',
  'scripts/event-dispatcher'
], function(
  $, _, Backbone,
  Component,
  _componentTemplate,
  dispatcher
) {
  return Component.extend({
    tagName: 'li',
    className: 'component-item',
    
    initialize: function() {
      this.template = _.template(_componentTemplate);
      this.$el.attr({
        'draggable': true,
        'data-name': this.model.get('title')
      })
    },

    render: function(withAttributes) {
      if (withAttributes) {
        return this.$el.html(
          this.template(this.model.getValues())
        ).attr({
          "data-title": this.model.get('title')
        });
      } else {
        return this.$el.html(
          this.template({
            'fields': this.model.getValues(),
            'title': this.model.get('title'),
            'title_zh': this.model.get('title_zh')
          })
        )
      }
    }
  })
})