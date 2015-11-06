define([
  'jquery', 'underscore', 'backbone',
  'scripts/event-dispatcher'
], function(
  $, _, Backbone,
  dispatcher
) {
  return Backbone.View.extend({

     el: $('.modal'),

     events: {
      'click': 'hideModal',
      'click .create': 'create'
     },

    render: function(temp) {
      this.$el.show();
      this.template = _.template(temp);
      this.$el.append(this.template());
      this.$form = this.$el.find('.model-form');
    },

    create: function(e) {
      e.preventDefault();
      var formVal = this.$form.serializeArray();
      var re = /^\w+$/g;
      // var isValid = _.every(formVal, function(item) {
      //   if (item.value !== '' && re.test(item.value)) {
      //     return true
      //   } else {
      //     return false
      //   }
      // })
      var isValid;
      if (formVal[0].value !== '' && re.test(formVal[0].value)) {
        isValid = true
      } else {
        isValid = false
      }

      if (isValid) {
        dispatcher.trigger('createPage', formVal);
        this.hideModal();
      } else {
        alert('请输入合法的信息')
      }
    },

    hideModal: function(e) {
      if (e && e.target !== this.$el[0]) return;
      this.$el.hide();
      this.$el.empty();
      this.undelegateEvents();
    }
  })
})