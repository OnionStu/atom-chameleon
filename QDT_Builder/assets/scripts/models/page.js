define([
  'jquery', 'underscore', 'backbone',
  'collections/customapp-components'
], function(
  $, _, Backbone,
  CustomAppCollection
) {
  return Backbone.Model.extend({

    initialize: function(attr, options) {
      console.log(options)
      // console.log(options.models);
      this.set('components', new CustomAppCollection(options));
      console.log(this)
    }
  })
})

