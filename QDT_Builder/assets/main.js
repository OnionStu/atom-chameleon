/* Todo:
 *  1. 处理路由方法未完善。
 *  2. require.js 的 optima。
*/

require.config({
  baseUrl: "../assets",
  shim: {
    'backbone': {
      deps: ['underscore', 'jquery'],
      exports: 'Backbone'
    },
    'underscore': {
      exports: '_'
    },
    'jquery': {
      exports: '$'
    }
  },
  paths: {
    collections: "scripts/collections",
    models: "scripts/models",
    views: "scripts/views",
    templates: "scripts/templates",
    data: "scripts/data",
    backbone: "bower_components/backbone/backbone-min",
    underscore: "bower_components/underscore/underscore-min",
    jquery: "bower_components/jquery/dist/jquery.min",
    text: "bower_components/text/text"
  }
});
require(['app', 'backbone', 'scripts/event-dispatcher'], function(app, Backbone, dispatcher) {
  
  
  var router = Backbone.Router.extend({

    initialize: function() {
      var appConfig = window.message;
      console.log (appConfig);
      new app(appConfig);
    },

    routes: {
      'pages/:id': 'renderPage'
    },

    triggerPanel: function(type) {
      $('.nav-item').removeClass('active');
      $('.nav-item.' + type).addClass('active');
      $('#' + type + '-panel').css({
        'display': 'inline-block'
      });
    },

    renderPage: function(id) {
      $('.left-panel-item').removeClass('active');
      $('a[href="#pages/'+id+'"]').parent().addClass('active');
      dispatcher.trigger('renderPage', id);
    }

  });

  new router();
  Backbone.history.start()
  
});