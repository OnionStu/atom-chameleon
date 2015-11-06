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
          componentScript = '',
          componentTop = '';

      _.each(this.collection.resultAll(), function(component) {
        console.log(component)
        if (component.componentScript) {
          componentScript += component.componentScript.outerHTML;
        }
        if (component.componentPos === 'top') {
          componentTop += component.componentView + '\n';
        } else {
          componentContent += component.componentView + '\n';
        }
      }.bind(this));


      var relaceStr = renderappTemp.replace(/<component-content>/i, componentContent);
      var topStr = relaceStr.replace(/<component-top>/i, componentTop);
      var finalHTML = topStr.replace(/<component-script>/i, componentScript);

      console.log(finalHTML);
      return finalHTML;
    }
  })
})