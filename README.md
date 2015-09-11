# 变色龙QDT使用文档
chameleon-qdt-atom  
***

* 前言
* 开发环境及基本要求
* 软件安装
	* 下载atom
	* atom的安装
	* QDT package安装
		* QDT package安装方式一
		* QDT package安装方式二
* 应用
	* 创建空白应用
	* 同步账号中的应用
	* 构建应用
	* 上传应用
* 模块
	* 创建模块
	* 模块上传
* 设置
	* 开发者账号
	* 框架、模板
* 常见问题

***

# 前言
该IDE主要是为利用变色龙框架进行移动 app 开发的 html5 前端人员，主要特色为：

* 配合变色龙云平台，可以快速构建你的 iOS、android 应用

## 开发环境及基本要求
* 安装git
* 下载并安装最新版atom

## 软件安装

### 下载atom

方式一：[https://atom.io/](https://atom.io/)，进入下atom主页：

![atom 主页](http://git.oschina.net/uploads/images/2015/0629/113205_fcc4d8a6_103655.jpeg "atom 主页")

方式二：[https://github.com/atom/atom#installing](https://github.com/atom/atom#installing)，进入下面界面：

![](http://git.oschina.net/uploads/images/2015/0611/170949_6c0ac6e3_103655.png "github atom 下载地址")

### atom的安装
atom的安装很方便，将下载过来的安装包`AtomSetup.exe`，点击安装，安装程序会自动下载依赖 .NET Framework 4.5.2。

![](http://7xifa4.com1.z0.glb.clouddn.com/QQ图片20150908095426.png)

安装完成后，点击`atom.exe`就能直接运行了。如下图：

![](http://7xifa4.com1.z0.glb.clouddn.com/QQ图片20150908100236.png)


### QDT package安装

#### QDT package安装方式一

1. 点击 Packages --> Settings View --> Install Packages/Themes，出现以下界面：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ图片20150908100319.png)

2. 在搜索框内输入 chameleon-test 进行搜索，出现以下界面：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ图片20150908100433.png)

3. 点击 Install 按钮进行下载安装 packages，等待下载完成，这个时间估计有点漫长，需要耐心：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ图片20150908100457.png)

5. 完成下载后，顶部菜单看上会出现 `变色龙QDT`：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ图片20150908104508.png)

6. 点击菜单`变色龙QDT`出现以下界面：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908151103.png)

#### QDT package安装方式二

1. 打开 [https://git.oschina.net/chameleon/chameleon-qdt-atom](https://git.oschina.net/chameleon/chameleon-qdt-atom)，点击网页上的`Download ZIP`, 下载IDE源码：
![](http://7xifa4.com1.z0.glb.clouddn.com/448AD6F3-5DE6-4BC0-8F35-6D88BDF3B7A1.png)

3. 将下载的压缩包解压到：`系统盘/用户/Administrator/.atom/packages`中
![](http://git.oschina.net/uploads/images/2015/0611/171949_c87ec1bc_103655.png)

4. 打开atom，顶部菜单栏上会多`变色龙QDT`：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ图片20150908104508.png)

5. 点击菜单`变色龙QDT`出现以下界面：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908151103.png)

*这种安装方式，需要通过命令行进入 `系统盘/用户/Administrator/.atom/packages/chameleon-qdt-atom`，执行`npm install`对库进行初始化*


## 应用

### 创建空白应用
1. 点击菜单 变色龙QDT --> 应用 --> 创建应用，打开以下界面：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908153808.png)

2. 选择 `创建应用` ，进入应用类型选择界面：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908153903.png)

3. 点击 `空白应用` 进入应用信息填写节面，填写相关信息：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908153946.png)

4. 点击`完成`即可创建应用：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908153955.png)
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908154009.png)

*选择`自带框架应用`或者`业务模板`，可以分别创建带有`butterfly`框架的应用和带有模板的应用。创建步骤与创建`空白应用`相同，这里不赘述。*

### 同步账号中的应用
1. 点击菜单 变色龙QDT --> 应用 --> 创建应用，打开以下界面：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908153808.png)

2. 选择 `创建应用` ，进入应用类型选择界面：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908164155.png)
*如果没有登录或者登陆超时，需要先登录后才可以同步*
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908164247.png)

3. 点击下一步，进入应用选择界面：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908164311.png)

4. 选择任一应用，点击下一步，进入应用信息填写节面，填写相关信息：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908164318.png)

5. 点击完成，即可同步成功：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908164332.png)

### 构建应用
1. 点击菜单 变色龙QDT --> 应用 --> 构建应用，打开需要构建的应用选择界面，可以选择已有应用或者添加本地应用：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908165642.png)
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908165649.png)

2. 选择项目后，点击下一步，选择需要构建的平台：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908165817.png)

3. 选择需要构建的平台后，填写对应信息：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908165825.png)

4. 耐心等待构建完成：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908165920.png)
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150909104219.png)

### 上传应用
1. 点击菜单 变色龙QDT --> 应用 --> 上传应用，打开需要上传的应用选择界面，可以选择已有应用或者添加本地应用：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908175435.png)

2. 点击 确认上传，等待上传成功：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908175549.png)

## 模块
### 创建模块
1. 点击菜单 变色龙QDT --> 模块 --> 创建模块 进行创建模块，打开以下界面，如果已在 atom 中打开了应用则可以选择对应应用：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908180800.png)
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908180841.png)

2. 点击 完成，等待模块创建完成：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908181729.png)

### 上传模块
1. 点击菜单 变色龙QDT --> 模块 --> 上传模块 选择模块所在的应用：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908182537.png)

2. 选择应用中需要上传的模块：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908182559.png)

3. 点击`下一步`，进入模块详情界面：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908182640.png)

4. 点击`上传`，即可上传模块（ *需要注意：上传模块的版本必须大于该模块在服务器上存在的版本* ）
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908182809.png)

5. 如果需要将新版本的模块应用到已关联的应用上，则可以点击`应用到`，选择需要关联的应用：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150908182822.png)

## 设置
点击菜单 变色龙QDT --> 设置，进入`设置`界面
### 开发者账号
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150909113331.png)
点击`登录`，可以进行账号登陆，只有登录后才能同步账号的应用和上传应用、构建应用：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150909113337.png)

### 框架、模板管理
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150909113442.png)
点击`添加`，可以添加框架：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150909113746.png)
添加成功后，可以更新、删除添加过的框架：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150909113434.png)

### 更新
点击 Packages --> Settings View --> Update Packages/Themes，出现以下界面：
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150910093816.png)
![](http://7xifa4.com1.z0.glb.clouddn.com/QQ截图20150910093919.png)
*如果可以更新，点击`UPdate to 版本号`即可进行更新*

## 常见问题
* 部分`windows`在安装完`git`后需要重启一下电脑，才能正常工作。
* `git`的网络请求可能会被360安全管家等同类软件拦截，选择`允许`即可。
