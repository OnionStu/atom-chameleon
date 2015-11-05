define([
  'jquery', 'underscore', 'backbone',
  'models/component',
  'views/customapp-component'
], function(
  $, _, Backbone,
  ComponentModel,
  CustomappComponentView
) {
  return Backbone.Collection.extend({
    model: ComponentModel,
    initialize: function() {
      console.log(this)
      this.on('add', this.giveUniqueId);
    },

    giveUniqueId: function(component) {

      if(!component.get('fresh')) return;
      component.set('fresh', false, {silent: true});
      var componentType = component.attributes.fields.id.value;
      component.setField('id', _.uniqueId(componentType + '_'));
    },

    renderAll: function() {
      return this.map(function(component){
        var customappComponentView = new CustomappComponentView({model: component});
        return customappComponentView.render();
      }.bind(this))
    },

    removeAll: function() {
      _.each(this.CustomappComponentViews, function(CustomappComponentView) {
        CustomappComponentView.remove();
      })
    },

    resultAll: function() {
      return this.map(function(component) {
        var componentView = new CustomappComponentView({model: component});
        var prefixTemp = componentView.splitTemp();
        return {
          componentView: prefixTemp[0],
          componentScript: componentView.renderScript(prefixTemp)
        }
      })
    }
  })
})