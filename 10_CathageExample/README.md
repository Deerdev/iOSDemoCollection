# Carthage的使用



---

## 1. Carthage和CocoaPods简介

简单介绍一下Carthage对于CocoaPods的优点：

- CocoaPods的缺点：
    - 每次更新库都需要去请求中心库服务器，获取最新版本信息
    - 每次clean后的编译都会把所有的库重新编译
    - 会修改xcode工程配置，使用Workspace

- Carthage的优点：
    - 去中心化，不需要去请求中心库服务器，只需要去请求更新具体对应的库信息即可
    - clean后，第三方库不会每一次都重新编译
    - 可以配合CocoaPods使用
    - 只要工程可以编译成Framework就可以使用Carthage
    - 不会修改xcode的工程（无干扰）
    
> `Carthage`只支持iOS8+后提供的动态framework

Carthage 和 Swift Package Manager的简单介绍：

```
Carthage vs Swift Package Manager

How about the differences between Carthage and Swift Package Manager?

The main focus of the Swift Package Manager is to share Swift code in a developer-friendly way. Carthage’s focus is to share dynamic frameworks. Dynamic frameworks are a superset of Swift packages since they may contain Swift code, Objective-C code, non-code assets (e.g. images) or any combinations of the three.

> Note: A package is a collection of Swift source files plus a manifest file.
The manifest file defines the package’s name and its content.
```

## 2. Carthage配置

### 2.1 安装

使用homebrew安装：

```
brew install carthage
```

### 2.2 查看和升级

```
// 查看：
carthage version
// 升级：
brew upgrade carthage
```

### 2.3 卸载

```
sudo brew uninstall carthage
```

## 3. Carthage第三方库配置

### 3.1 创建[Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile)

```
// 1.进入工程目录
cd ~/project
// 2.创建Cartfile
touch Cartfile
```

### 3.2 用Xcode打开/编辑Cartfile

```
open -a Xcode Cartfile
```

### 3.3 添加依赖库

```
github "Alamofire/Alamofire" == 4.5
github "Alamofire/AlamofireImage" ~> 3.2
```
> - Dependency origin: project的位置
github：来自Github
git: 来自git仓库
- 使用 `Username/ProjectName` 指定一个project

> - 版本的含义:
~>3.0: 表示使用版本3.0以上但是低于4.0的最新版本，如3.5, 3.9。
>=3.0: 表示大于3.0的版本
==3.0: 表示使用3.0版本。
>=3.0: 表示使用3.0或更高的版本。
如果你没有指明版本号，则会自动使用最新的版本。

> - 指定branch name / tag name / commit name:
使用指定的 "branch / tag / commit"
(例如：分支"master"、提交"5c8a74a")

```
# 使用最新的版本
github "jspahrsummers/xcconfigs"

// 加载任意git，development分支
git "https://enterprise.local/desktop/git-error-translations2.git" "development"

// 加载本地project，指定branch分支
git "file:///directory/to/project" "branch"

# A binary only framework
binary "https://my.domain.com/release/MyFramework.json" ~> 2.3
```

### 3.4 安装/编译Cartfile中的project

carthage clone代码，然后编译成Framework:
```
// 不指定platform 会为所有的平台编译（Mac / iOS）
// 查看更多关于update命令的选项：`carthage help update`
carthage update --platform iOS
```

> Cartfile利用xcode-select命令来编译Framework，如果你想用其他版的Xcode进行编译，执行下面这条命令，把xcode-select的路径改为另一版本Xcode就可以。
`sudo xcode-select -s /Applications/Xcode-beta.app/Contents/Developer`


所有的文件会被编译到当前路径的`Carthage`文件夹中：

```
// 打开文件夹
open Carthage
```

`Carthage`文件夹中文件说明:


![carthage-directory-21-430x500.png-100.8kB][1]


- `Cartfile.resolved`:
  Cartfile的附属文件，记录当前安装库的版本号；强烈建议将该文件加入到版本控制中，告知其他开发者，当前使用的版本。
- Carthage文件夹：（是否加入版本控制，由开发者自己考虑）
    - `Build`:
      包含对应平台编译好的Framework
    - `Checkouts`: 
      包含编译Framework所使用的源代码（不要修改这里的代码，`carthage update` 和 `carthage checkout`会覆盖这里的代码，清除你的修改）


### 3.5 (附)更新Framework的版本

- 打开Cartfile
```
open -a Xcode Cartfile
```

- 修改版本

```
// github "Alamofire/Alamofire" == 4.5
github "Alamofire/Alamofire" ~> 4.5.0
```

- 更新
```
carthage update --platform iOS
```

- 更新指定库
```
carthage update SVProgressHUD --platform iOS
```

## 4. 引入Carthage依赖库到Xcode

- 在`Carthage`->`Build`中找到需要添加的Framework
- 拖拽对应的Framework到Xcode工程的`Linked Frameworks and Libraries`中

![navigation.gif-313.9kB][2]

> 也可以直接设置Xcode自动搜索Framework的目录：
  Target—>Build Setting—>Framework Search Path—>添加路径`"$(SRCROOT)/Carthage/Build/iOS"`

- 进入工程的 target -> `Build Phases`，点击“+”，添加“`New Run Script Phase`”:

![add_run_script-650x405.png-124.9kB][3]

添加如下脚本命令：
```
/usr/local/bin/carthage copy-frameworks
```
添加一下`Input Files`:

```
$(SRCROOT)/Carthage/Build/iOS/Alamofire.framework
$(SRCROOT)/Carthage/Build/iOS/AlamofireImage.framework
```

> 该命令的目的：
当App提交到App Store时，如果App的Framework包含了iOS模拟器的binary images，会被拒绝[ App Store submission bug](http://www.openradar.me/radar?id=6409498411401216)。所以`carthage copy-frameworks`命令是为了移除Framework多余的模拟器架构(变通方案)。

至此，基本的Carthage使用已经介绍完成，下面将介绍更多关于Carthage的用法。

## 5. 引入Carthage依赖库的调试信息到Xcode

- 在工程的 target -> Build Phases，点击“+”，添加“`New Copy Files Phase`”;
- 点击 `Destination`下拉菜单，选择 “`Products Directory`”;
- 添加Framework对应的dSYM文件

![WX20180109-192146.png-54.4kB][4]
![WX20180109-191945.png-143.9kB][5]

> 加入调试信息到工程中后，Xcode在依赖库中中断时，可以符号化调用堆栈，查看依赖库的调用堆栈。
Archive工程时，Xcode也会拷贝这些调试信息到.xcarchive bundle 的 dSYMs 子目录中。

## 6. 引入Carthage依赖库到单元测试或者某个Framework中

单元测试等非应用类的targets在构建设置中没有“Embedded Binaries”/“Linked Frameworks and Libraries”选项，所以需要拖拽Framework到build phases选项中的“Link Binaries With Libraries”:
![WX20180109-194300.png-43.2kB][6]

> 在很少情况下，可能要拷贝每个依赖到自己的构建项目（比如，在外部 framework 中嵌入依赖，或者确保依赖在 test bundle 中出现）。怎么做呢？在 Build Phases 选项下点击左上角 “＋” 按钮，选择 “New Copy Files Phases”，然后在 Copy Files 选项下的 Destination 选择器中选择 Frameworks，同时添加 framework 的引用。

## 7. 嵌套依赖

依赖库本身还依赖其他的库，需要显式在Cartfile中写出，并且手动拖拽到自己的项目中。


## 8. 使用submodules做依赖

如果必须要修改`Checkouts`中的源代码，当运行`carthage update`命令时，可以添加`--use-submodules`选项，该命令会使得Carthage把添加的依赖库作为一个子模块（git submodules）。这样就可以在`Checkouts`中的源代码内部commit，push。

运行之后，Carthage 会在仓库中写入 .gitmodules 和 .git/config 文件，并自动更新当依赖的版本发生变化的时候。

> 查看git submodule:

> - [Git 工具 - 子模块](https://git-scm.com/book/zh/v2/Git-%E5%B7%A5%E5%85%B7-%E5%AD%90%E6%A8%A1%E5%9D%97)
> - [使用Git Submodule管理子模块](https://segmentfault.com/a/1190000003076028)

如果自己没有提交自己修改的Framework到工程中，那么其他人拉取工程后需要运行`carthage bootstrap`，该命令会下载并编译Cartfile.resolved中你指定版本的源代码。不可以使用`carthage update`，会覆盖成官方版本。

## 9. 自动构建依赖库

在工程中，如果修改了依赖库中的代码，并且想在编译父工程的时候重新编译依赖库，可以添加Run Script来调用Carthage编译依赖库：

```
/usr/local/bin/carthage build --platform "$PLATFORM_NAME" "$SRCROOT"
```

> 因为修改了依赖库的代码，所以需要使用submodules

## 10. 让自己的工程支持Carthage

Carthage只支持dynamic framework，并且没有中心化的package list，不需要像CocoaPods一样给项目添加说明文件。大部分的framework都是自动编译的。

### 10.1 分享你的工程的Xcode schemes

Carthage只能构建已经分享Xcode schemes的.xcodeproj工程，通过运行`carthage build --no-skip-current`来查看你的所有的intended schemes是否构建成功，然后检查Carthage/Build文件夹是否有编译成功的framework。

如果运行命令时，有一个重要的scheme没有构建，可以打开Xcode确保“[scheme is marked as ‘Shared’](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/xcode_guide-continuous_integration/ConfigureBots.html#//apple_ref/doc/uid/TP40013292-CH9-SW3)”，这样Carthage就可以发现它。

![image.png-138.8kB][7]

### 10.2 解决构建失败

若运行`carthage build --no-skip-current`时，构建失败，可以尝试运行以下命令，如果出错，会有更多的信息帮助你解决问题。

```
// (WORKSPACE为具体name.xcworkspace)
xcodebuild -scheme SCHEME -workspace WORKSPACE build
// 或者 
// (PROJECT为具体name.xcodeproj)
xcodebuild -scheme SCHEME -project PROJECT build
```

如果你安装了多个Apple developer tools（比如Xcode beta），可以使用`xcode-select`选择一个具体的版本供Carthage使用。

### 10.3 给稳定的版本打tag

Carthage是通过搜索发布到仓库的tag来判断framework的哪个版本是可用的，并且最好使用[semantic version](https://semver.org/)来命名，比如tag `v1.2`，语义版本是`1.2.0`。

目前，不支持没有数字版本号的tag，或者任何字符跟在数字版本号后面（比如：`1.2-alpha-1`），不支持的tag会被忽略。

### 10.4 将预构建的framework归档到zip文件

如果你的工程依附[GitHub Release](https://help.github.com/articles/about-releases/)，Carthage会自动使用预编译的framework，而不是从头开始构建。

为了给预构建的framework添加指定tag，支持所有平台的库的二进制文件要打包进一个zip文件，并且该zip要附加到已发布版本的tag下。zip文件的命名要包含`.framework`(例如 `ReactiveCocoa.framework.zip`)，来告知Carthage这个zip里有二进制文件。

可以使用`carthage archive`打包zip包：

```
carthage build --no-skip-current
carthage archive YourFrameworkName
```

> 也可以通过travis-ci自动上传prebuild frameworks：[Use travis-ci to upload your tagged prebuild frameworks](https://github.com/Carthage/Carthage/blob/master/README.md#use-travis-ci-to-upload-your-tagged-prebuild-frameworks)


### 10.5 构建静态库来加快App的启动

过多的dynamic frameworks会减慢app的启动时间，Carthage可以通过把`动态库`构建成`静态库`来优化启动时间。具体方法查看[StaticFrameworks doc](https://github.com/Carthage/Carthage/blob/master/Documentation/StaticFrameworks.md)。

但是需要注意：

- Swift官方还不支持静态库；
- 这是一个还没有加入到Carthage中的高级方法。

### 10.6 声明自己的工程支持Carthage

添加兼容的badge到README文件，在Markdown中插入以下链接：

```
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
```


## 参考：

1. [Carthage](https://github.com/Carthage/Carthage/blob/master/README.md)
2. [(译)Carthage 使用说明](http://devtian.me/2015/08/11/translate-carthage-readme/)
3. [Carthage Tutorial: Getting Started](https://www.raywenderlich.com/165660/carthage-tutorial-getting-started-2)
4. [Carthage安装及使用](https://www.jianshu.com/p/52dff4cef8a2)


  [1]: http://static.zybuluo.com/Sweetfish/gu9xivxxoc3jelp6y4xzkz47/carthage-directory-21-430x500.png
  [2]: http://static.zybuluo.com/Sweetfish/83tjl4leqogabfvqmop5veu1/navigation.gif
  [3]: http://static.zybuluo.com/Sweetfish/wrqln7il6emhdtm1et7ya7kk/add_run_script-650x405.png
  [4]: http://static.zybuluo.com/Sweetfish/wg9v736rtf9o1scs1gl0yzwc/WX20180109-192146.png
  [5]: http://static.zybuluo.com/Sweetfish/na6u46tbtyhd4n743hgd6x9u/WX20180109-191945.png
  [6]: http://static.zybuluo.com/Sweetfish/ontqogztamjoln97jkwilsm3/WX20180109-194300.png
  [7]: http://static.zybuluo.com/Sweetfish/jqrhvn3jmpurgrusx823jbge/image.png

