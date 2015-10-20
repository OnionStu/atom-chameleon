Path = require 'path'

module.exports = TextDescription =
  headtitle : '标题'
  cancel : '取消'
  next : '下一步'
  prev : '上一步'
  upload : '上传'
  back : '返回'
  finish : '完成'
  save : '保存'
  recovery : '还原'
  login : '登录'
  logout : '退出登录'
  email : '邮箱'
  pwd : '密码'
  save : '保存'
  forgetPwd: '忘记密码'
  other: '其他'
  openFromFolder: '从文件夹打开'

  createProject : '创建应用'
  createAppType: '请选择要创建的应用类型'
  emptyApp: '空白应用'
  createLocalAppDesc: '创建一个本地应用'
  syncAccountAppDesc: '同步已登录帐户中的应用到本地，未登录的用户请登录'

  createModule : '创建模块'
  createModuleTitle: '请填写要创建的模块信息'
  createModuleType: '请选择要创建的模块类型'
  selectProjectPath: '请选择应用目录'
  modulePath: '独立模块(保存目录)'
  moduleInApp: '基于应用'
  moduleId: '模块标识'
  moduleName: '模块名称'
  mainEntry: '模块入口'
  createModuleSuccess: '创建模块成功！'
  createModuleError: '模块创建失败'


  emptyModule: '空白模块'
  simpleMoudle: '页面快速搭建'
  defaultTemplateModule:'自定义框架'

  selectModuleTemplate: '请选择模块模板'



  createModuleErrorMsg: '模块或同名目录已存在'
  moduleIdErrorMsg:'模块标识以字母开头,长度必须在6-32个字符范围内,只能输入数字,字母,下划线'

  newProject: '新建应用'

  syncProject: '同步账号中的应用'

  registerUrl : 'http://www.baidu.com'

  gitFolder: '.git'
  gitCloneError: 'git clone失败，请检查网络连接'

  chameleonHome: atom.packages.getLoadedPackage('chameleon-qdt-atom-dev').path
  newProjectDefaultPath: atom.config.get('core').projectHome

  # 获取自带框架存储目录位置
  getFrameworkPath: ->
    Path.join @chameleonHome,'src','frameworks'

  # 获取空白模版存储目录位置
  getProjectTempPath: ->
    Path.join @chameleonHome,'src','ProjectTemp'

  # 获取业务模板存储目录位置
  getTemplatePath: ->
    Path.join @chameleonHome,'src','templates'

  getImgPath:(imgName) ->
    Path.join @chameleonHome,'images',imgName

  mainEntryFileName: 'index.html'


  publishModule: "上传模块"
  publishModulePageOneTitle: '请选择需要发布的模块'
  publishModulePageTwoTitle: '确认发布模块信息'

  moduleConfigFileName: 'module-config.json'
  ProjectConfigFileName: 'app-config.json'

  projectConfig : '应用配置'
  moduleConfig : '模块配置'

  defaultModule : 'butterfly-tiny'
  minVersion : '0.0.1'

  # 设置模块
  panelTitle: '设置'
  menuAccount: '开发者账号'
  menuCode: '框架、模版'

  buildProjectMainTitle: "构建应用"
  uploadProjectTitle: "上传应用"

  moduleLogoFileName: 'icon.png'
  moduleLocatFileName: 'modules'
