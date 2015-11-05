define(['backbone'], function(Backbone){
  var dispatcher = {};
  _.extend(dispatcher, Backbone.Events);

  dispatcher.on('dragstart', function(e) {});

  dispatcher.on('dragend', function(e) {});

  dispatcher.on('disDraggable', function(e) {});

  dispatcher.on('enDraggable', function(e) {});

  dispatcher.on('deleteModel', function(e) {});

  dispatcher.on('hideSettingPanel', function(e) {});

  dispatcher.on('createPage', function(e) {});

  dispatcher.on('renderPage', function(e) {});
  
  return dispatcher
})