define([
  'jquery', 'underscore', 'backbone',
  'views/modal',
  'text!templates/app/create-modal.html',
  'scripts/event-dispatcher'
], function(
  $, _, Backbone,
  ModalView,
  CreateModalTemp,
  dispatcher
) {
  return Backbone.View.extend({
    el: $('#pages-panel .left-panel-list'),

    initialize: function() {
      $('.create-page').on('click', function() {
        (new ModalView()).render(CreateModalTemp);
      }.bind(this))
      this.render();
      this.collection.on('add', this.render, this);
      this.listenTo(dispatcher, 'createPage', this.createPage)
    },

    render: function() {
      this.$el.empty();
      _.each(this.collection.renderAll(), function(PageItem) {
        this.$el.append(PageItem)
      }.bind(this))
    },

    createPage: function(val) {
      console.log(val)
      this.collection.add({name: val[0].value + '.html'})
    }
  })
})