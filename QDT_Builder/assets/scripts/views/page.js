define([
	'jquery', 'underscore', 'backbone',
	'text!templates/pages/page.html'
], function(
	$, _, Backbone,
	PageView
){
	return Backbone.View.extend({
		tagName: 'li',

		className: 'left-panel-item',

		initialize: function() {
			this.template = _.template(PageView);
		},

		render: function() {
			return this.$el.html(
				this.template(this.model.attributes)
			)
		}
	})
})