define([
  'jquery', 'underscore', 'backbone',
  'views/page',
  'models/page'
], function(
  $, _, Backbone,
  PageItemView,
  PageModel
) {
  return Backbone.Collection.extend({

    model: function(attr, options) {
      var components = !_.isUndefined(attr.components) ? attr.components : [];
      return new PageModel({name: attr.name}, components)
    },

    renderAll: function() {
      return this.map(function(page){
        return new PageItemView({model: page}).render()
      })
    }
  })
})