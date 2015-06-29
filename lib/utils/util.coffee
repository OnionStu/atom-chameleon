module.exports= Util =

  rumAtomCommand: (command) ->
     atom.views.getView(atom.workspace).dispatchEvent(new CustomEvent(command, bubbles: true, cancelable: true))

  getIndexHtmlCore: ->
    """
    <!DOCTYPE html>
    <html lang="zh-CN">
      <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no, minimal-ui">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-status-bar-style" content="black">
        <title>Empty Template</title>
      </head>
      <body>
        <h1>Hello World!</h1>
      </body>
    </html>
    """

  formatModuleConfig:(options) ->
    """
    {
      "name": "#{options.moduleName}",
      "identifier": "#{options.moduleId}",
      "main":"#{options.mainEntry}",
      "version": "0.0.1",
      "description": "",
      "dependencies": {},
      "releaseNote": "module init",
    }
    """

  formatAppConfig:(options) ->
    """
    {
      "name": "#{options.appName}",
      "identifier": "#{options.appId}",
      "mainModule":"#{if options.mainModule? then options.mainModule else '' }",
      "version": "0.0.1",
      "description": "",
      "dependencies": {},
      "releaseNote": "app init",
    }
    """