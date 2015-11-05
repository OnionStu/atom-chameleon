define(function(require) {
  var header = require('text!templates/components/header.html'),
  			 nav = require('text!templates/components/nav.html'),
  			 tab = require('text!templates/components/tab.html'),
  			 list = require('text!templates/components/list.html');
  
  return {
    header: header,
       nav: nav,
       tab: tab,
      "content-list": list
  }
})