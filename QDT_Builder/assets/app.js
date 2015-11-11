define([
  'jquery', 'underscore', 'backbone',
  'collections/storehouse-components', 'collections/customapp-components', 'collections/pages',
  'views/customapp', 'views/storehouse', 'views/renderapp', 'views/pages', 'views/modal',
  'text!data/components.json', 'text!data/custom.json', 'text!data/pages.json',
  'scripts/event-dispatcher'
], function(
  $, _, Backbone,
  StorehouseCollection, CustomAppCollection, PagesCollection,
  CustomAppView, StorehouseView, renderappView, pagesView, modalView,
  componentsJSON, customJSON, pagesJSON,
  dispatcher
) {
  return Backbone.View.extend({

    el: document.querySelector('#app'),

    events: {
      'click #right-container': 'hideSettingPanel',
      'click .nav-item': 'triggerTab'
    },

    initialize: function(appConfig) {
      var PagesJSON = appConfig.builderConfig;
      // var PagesJSON = JSON.parse('[]');
      // var PagesJSON = JSON.parse(pagesJSON)
      console.log(PagesJSON)
      
      this.$iframe = this.$el.find('#iframe-container');

      this.PagesCollection = new PagesCollection(PagesJSON);
      this.pagesView = new pagesView({ 
        collection: this.PagesCollection
      });
      this.customAppView;
      this.render();
      
      $('#publish').on('click', function() {
        console.log(this.PagesCollection)
        var PageCollection = this.PagesCollection.toJSON();
        _.each(this.PagesCollection.models, function(pageCollection, index) {
          var newstr = (new renderappView({collection: pageCollection.attributes.components})).render();
          PageCollection[index].components = pageCollection.attributes.components.toJSON();
          PageCollection[index].html = newstr;
        })
        
        var message = {
          PageCollection: PageCollection,
          appConfig: appConfig
        }
        var pageInfo = JSON.stringify(message);
        window.parent.postMessage(pageInfo, '*');
      }.bind(this));

      this.listenTo(dispatcher, 'renderPage', this.renderPage)
    },

    render: function() {
      var storehouseView = new StorehouseView({
        collection: new StorehouseCollection(JSON.parse(componentsJSON))
      });
      storehouseView.render();
    },

    renderPage: function(id) {
      var currentPageCollection = this.PagesCollection.findWhere({name: id}).attributes.components;
      var $body = $(this.$iframe[0].contentWindow.document.body);

      if (this.customAppView) {
        $body.find('.component-script').remove();
        this.customAppView.remove();
        this.customAppView = null;
      }

      this.customAppView = new CustomAppView({
        collection: currentPageCollection,
        $body: $body
      })

      $body.find('.page-current').append(this.customAppView.render())
      
    },

    hideSettingPanel: function(e) {
      dispatcher.trigger('hideSettingPanel', e)
    },

    triggerTab: function(e) {
      var $target = $(e.currentTarget);
      var currentTab = $target.data('for');
      $('.nav-item').removeClass('active');
      $target.addClass('active');
      $('.left-panel').removeClass('active')
      $('#' + currentTab + '-panel').addClass('active');
    }
  })
})