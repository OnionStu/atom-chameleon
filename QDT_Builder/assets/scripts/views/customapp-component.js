define([
  'jquery', 'underscore', 'backbone',
  'views/component', 'views/popover',
  'templates/components/components-templates',
  'scripts/event-dispatcher'
], function(
  $, _, Backbone,
  Component, popoverView,
  _componentTemplates,
  dispatcher
){
  return Component.extend({
    initialize: function() {
      console.log(this.model)
      this.template = _.template(_componentTemplates[this.model.get('title')]);
      if ( this.model.get('title') !== 'header'){
        this.$el.attr('draggable', true);
      }
      this.$el.attr({
        'data-id': this.model.attributes.fields.id.value,
        'data-cid': this.model.cid,
        'data-isfixed': this.model.get('fixed')
      });
      this.$SettingContainer = $('#component-setting');
      this.iframeDocment = $('#iframe-container')[0].contentWindow.document;
      this.constructor.__super__.initialize.call(this);
    },

    render: function() {
      var prefixTemp = this.splitTemp();
      var renderScript = this.renderScript(prefixTemp);
      if (renderScript) {
        this.iframeDocment.body.appendChild(renderScript);
      }
      return this.$el.html(
        prefixTemp[0]
      )
    },

    renderScript: function(prefixTemp) {
      // var prefixTemp = this.splitTemp();
      if (prefixTemp.length > 1) {
        var script = this.iframeDocment.createElement('script');
        var scriptId = this.model.getValues().id + '-script';
        script.id = scriptId;
        script.className = 'component-script';
        script.type = "text/javascript";
        script.innerHTML = prefixTemp[1];
        return script;
      } else {
        return false;
      }
    },

    splitTemp: function() {
      var temp = this.template(this.model.attributes);
      if (temp.indexOf('<script>') > 0 && temp.indexOf('</script>') > 0) {
        var originScript = temp.substring(temp.indexOf('<script>'), temp.indexOf('</script>') + 9);
        var scriptStr = originScript.substring(originScript.indexOf('<script>') + 8, originScript.indexOf('</script>'));
        var newStr = temp.replace(originScript, '');
        return [newStr, scriptStr];
      } else {
        return [temp];
      }
    },

    dragstartHandler: function(e) {
      // e.preventDefault();
      // e.stopPropagation();
      this.constructor.__super__.dragstartHandler.call(this, e);
    }
  })
})