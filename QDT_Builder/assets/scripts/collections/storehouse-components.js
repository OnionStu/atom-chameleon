define([
  'jquery', 'underscore', 'backbone',
  'models/component',
  'views/storehouse-component'
], function(
  $, _, Backbone,
  ComponentModel,
  StorehouseComponentView
) {
  return Backbone.Collection.extend({
    model: ComponentModel,
    renderAll: function() {
      return this.map(function(component){
        return new StorehouseComponentView({model: component}).render();
      })
    }
  })
})