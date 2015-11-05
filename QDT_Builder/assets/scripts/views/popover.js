define([
  'jquery', 'underscore', 'backbone',
  'text!templates/popover/popover-main.html',
  'text!templates/popover/popover-input.html',
  'text!templates/popover/popover-select.html',
  'scripts/event-dispatcher'
], function(
  $, _, Backbonem,
  _PopoverMain,
  _popoverInputTemp,
  _popoverSelectTemp,
  dispatcher
){
  return Backbone.View.extend({
    tagName: 'div',
    className: 'popover-container',
    events: {
      'click #cancel': 'removePopover',
      'click #save': 'save',
      'click #delete': 'delete',
      'click': 'preventDefault'
    },
    initialize: function(options) {
      this.options = options;
      this.$SettingContainer = $('#component-setting');
      this.template = _.template(_PopoverMain);
      this.popoverTemplates = {
        'input': _.template(_popoverInputTemp),
        'select': _.template(_popoverSelectTemp)
      }
    },

    render: function() {
      return this.$el.html(
        this.template({
          'title': this.model.get('title_zh'),
          'items': this.model.get('fields'),
          'popoverTemplates': this.popoverTemplates
        })
      )
    },

    removePopover: function(e) {
      e.preventDefault();
      this.remove();
      this.options.parentView.$el.find('.component.active').removeClass('active');
      this.$SettingContainer.hide();
    },

    delete: function(e) {
      e.preventDefault();
      dispatcher.trigger('deleteModel', this.model);
    },

    save: function(e) {
      e.preventDefault();
      var settingValues = this.$el.find('#setting-form').serializeArray();
      var defaultValues = this.model.getValues();
      var isequal = _.every(settingValues, function(settingValue) {
        if (settingValue.value !== defaultValues[settingValue.name]){
          return false;
        } else {
          return true;
        }
      })
      var fields = this.$el.find('#setting-form .field');
      if (!isequal) {
        _.each(fields, function(e) {
          var $e   = $(e);
          var type = $e.attr('data-type');
          var name = $e.attr('id');
          switch(type) {
            case 'input':
              this.model.setField(name, $e.val());
              break;
            case 'select':
              var valarr = _.map($e.find("option"), function(e){
                return {value: e.value, selected: e.selected, label: $.trim($(e).text())};
              });
              this.model.setField(name, valarr);
              break;
          }
        }.bind(this));
        this.model.trigger('change', this.model);
        console.log(this.model)
      } else {
        console.log('no')
      }
    },
    preventDefault: function(e) {
      e.stopPropagation()
    }
  })
})