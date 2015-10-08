{$, Emitter, Directory, File, GitRepository, BufferedProcess} = require 'atom'
Util = require '../utils/util'
pathM = require 'path'
desc = require '../utils/text-description'
ChameleonBox = require '../utils/chameleon-box-view'
CreateModuleView = require './create-module-view'
fs = require 'fs-extra'

module.exports = ModuleManager =
  chameleonBox: null
  modalPanel: null

  activate: (state) ->
    @chameleonBox = new CreateModuleView()

    @chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
    @chameleonBox.move()

    @chameleonBox.onFinish (options) => @CreateModule(options)
    @chameleonBox

  deactivate: ->
    @modalPanel.destroy()
    @chameleonBox.destroy()

  serialize: ->
    chameleonBoxState: @chameleonBox.serialize()

  openView: ->
    unless @modalPanel.isVisible()
      console.log 'CreateModuleView was opened!'
      @modalPanel.show()


  CreateModule: (options)->
    switch options.createType
      when 'empty' then @CreateEmptyModule options
      when 'simple' then @CreateSimpleModule options
      when 'template' then @CreateTemplateModule options


  CreateEmptyModule: (options) ->
    console.log options
    info = options.moduleInfo
    filePath = pathM.join info.modulePath,info.moduleId
    configFilePath = pathM.join filePath,desc.moduleConfigFileName
    configFile = new File(configFilePath)
    configFileContent = Util.formatModuleConfigToObj(info)
    entryFilePath = pathM.join filePath,info.mainEntry
    entryFile = new File(entryFilePath)
    htmlString = Util.getIndexHtmlCore()
    isProject = options.isChameleonProject
    configFile.create()
      .then (isSuccess) =>
        console.log isSuccess
        if isSuccess is yes
          configFile.setEncoding('utf8')
          console.log 'CreateModule Success'
          cb = (err) =>
            console.log err
          Util.writeJson(configFilePath,configFileContent,cb)
          entryFile.create()
        else
          console.log 'CreateModule error'
      .then (isSuccess) =>
        if isSuccess is yes
          entryFile.writeSync(htmlString)
          @addProjectModule info
          isInProject = false
          atom.project.getDirectories().forEach (dir) =>
            # console.log dir,filePath
            flag = dir.contains filePath
            # console.log flag
            if flag
              isInProject = flag

          console.log isInProject
          if isInProject is no
            atom.project.addPath(filePath)
            Util.rumAtomCommand 'tree-view:toggle' if ChameleonBox.$('.tree-view-resizer').length is 0
          alert "新建模块成功！"
          @chameleonBox.closeView()
      # .finally =>
        # console.log 'CreateModule Success',@

  CreateSimpleModule: (options) ->

  CreateTemplateModule: (options) ->

  addProjectModule: (moduleInfo) ->
    console.log moduleInfo
    if moduleInfo.isChameleonProject is yes
      projectConfigPath = pathM.join moduleInfo.modulePath, '..', desc.ProjectConfigFileName
      appConfig = Util.readJsonSync projectConfigPath
      appConfig.mainModule = moduleInfo.moduleId if appConfig.mainModule is ''
      appConfig.modules[moduleInfo.moduleId] = desc.minVersion
      Util.writeJson projectConfigPath,appConfig,(err) ->
        console.log err
