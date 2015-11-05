define([
  'jquery', 'underscore', 'backbone',
  'text!templates/app/renderapp.html'
], function(
  $, _, Backbone,
  renderappTemp
) {
  return Backbone.View.extend({
    render: function() {
      var componentContent = '',
           componentScript = '';

      _.each(this.collection.resultAll(), function(component) {
        if (component.componentScript) {
          componentScript += component.componentScript.outerHTML
        }
        componentContent += component.componentView + '\n';
      }.bind(this));

      var relaceStr = renderappTemp.replace(/<component-content>/i, componentContent);
      var finalHTML = relaceStr.replace(/<component-script>/i, componentScript);

      console.log(finalHTML);
      return finalHTML;
    }
  })
})