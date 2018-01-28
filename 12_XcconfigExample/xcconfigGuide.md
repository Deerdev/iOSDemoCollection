
## 1.简介

xcconfig文件可以给Xcode的build提供configuration的信息，这样就可以通过多个xcconfig文件为build配置多个环境（开发环境、生产环境等）。

## 2.xcconfig文件语法

### 2.1 注释

- 以`//`开头注释一行
- 只有一行注释，没有多行注释


### 2.2 Include声明

- 可以通过`#include`包含一个双引号包裹的路径

```
#include "./release.xcconfig"
```

### 2.3 变量

- 变量可以以`_`开头或者大写/小写字母
- 可以包含以下字符：
    - 下划线`_`
    - 数字`0-9`
    - 字母`a-z`和`A-Z`

### 2.4 赋值

- 通过`=`给变量赋值

### 2.5 行数

- 每一行作为一个命令，同一命令不能多行书写
- 如果一行以`;`结尾，`;`会被忽略，即`;`不能作为行的分隔符

### 2.6 字符串

- 字符串可以是`"`或`'`包裹

> 语法出错，Xcode会报错

## 3.include声明

`#include`路径的指定：

```
// 包含完整路径
#include "/Users/sam/Documents/shared.xcconfig" 

// 包含的文件和当前文件在同一目录
#include "default.xcconfig" 

// 在当前文件的上级目录OtherConfigs中
#include "../OtherConfigs/Shared.xxconfig" 

// 在$(DEVELOPER_DIR)目录下（https://pewpewthespells.com/blog/buildsettings.html#developer_dir）
#include "<DEVELOPER_DIR>/Makefiles/CoreOS/Xcode/BSD.xcconfig"
```

## 4.变量赋值

`=`两边保留空格，多个空格也是合法的。

### 4.1 overriding

Project或target的Build setting中的配置会被xcconfig中的配置overridden。

下面代码中，编译后，`-ObjC`的值会被`-framework Security`替代：

```
// Variable set in the project file
OTHER_LDFLAGS = -ObjC

// lib.xcconfig
OTHER_LDFLAGS = -framework Security
```

### 4.2 Inherit

xcconfig可以通过`$(inherited)`继承Project或target的Build setting，使得两个配置都会生效。

以下代码中，编译后，`OTHER_LDFLAGS`值会变为`-ObjC -framework Security`：

```
// Variable set in the project file
OTHER_LDFLAGS = -ObjC

// lib.xcconfig
OTHER_LDFLAGS = $(inherited) -framework Security
```

## 5. 条件变量赋值

可以根据不同的条件判断变量的具体赋值，比如根据OS的版本来修改linker flags。判断条件支持使用通配符`*`。

条件赋值优先于普通赋值：

```
FOO              = bar
FOO[sdk=macosx*] = buzz
```

如果target在OS X和iOS上分别编译，则build setting看来可能如下：

```
|-- FOO                 =   bar
    |--   Any Mac SDK   =   buzz
    |--   Any iOS SDK   =   bar     // 继承FOO的原始赋值
```

多个条件可以组合：

```
// 该判断条件只针对OS X的SDK并且是32bit的Intel架构
FOO[sdk=macosx*][arch=i386] = bar 
```

多个条件组合可以有以下方式：

```
FOO[sdk=<sdk>][arch=<arch>] = ...
FOO[sdk=<sdk>,arch=<arch>] = ...
```

主要的条件判断有一下几种：SDK, Architecture, Build Configuration name, Build Variant, and Dialect。

### 5.1 SDK

sdk判断条件主要基于[$(SDKROOT)](https://pewpewthespells.com/blog/buildsettings.html#sdkroot)，根据选择的SDK版本，配置具体的值：

```
FOO[sdk=macosx10.8]         = ...   // For building against the 10.8 SDK 
FOO[sdk=macosx10.9]         = ...   // For building against the 10.9 SDK 
FOO[sdk=macosx10.10]        = ...   // For building against the 10.10 SDK 
FOO[sdk=macosx*]            = ...   // For building against any Mac OS X SDK

FOO[sdk=iphoneos*]          = ...   // For building against any iOS SDK
FOO[sdk=iphonesimulator*]   = ...   // For building against any iOS Simulator SDK

FOO[sdk=*]                  = ...   // For building against any SDK
```

### 5.2 Arch

arch的判断条件主要基于[$(CURRENT_ARCH)](https://pewpewthespells.com/blog/buildsettings.html#current_arch)。而`$(CURRENT_ARCH)`的build setting来自于[\$(ARCHS)](https://pewpewthespells.com/blog/buildsettings.html#archs)。

```
FOO[arch=i386]      = ...   // For building to target 32bit Intel 
FOO[arch=x86_64]    = ...   // For building to target 64bit Intel 

FOO[arch=armv7]     = ...   // For building to target ARM v7
FOO[arch=arm64]     = ...   // For building to target ARM64
FOO[arch=arm*]      = ...   // For building to target any ARM

FOO[arch=*]         = ...   // For building to target any architecture
```

### 5.3 Config

configuration的判断条件主要基于[$(CONFIGURATION)](https://pewpewthespells.com/blog/buildsettings.html#configuration)。configuration的条件赋值可能和想象的不一样，和`[sdk=]`和`[arch=]`不一样的是`[config=]`的条件会隐式的加上`[sdk=*]`和`[arch=*]`两个条件，例如下面的代码：

```
ONLY_ACTIVE_ARCH[config=Debug] = YES
```

实际上是这样的：

```
ONLY_ACTIVE_ARCH[config=Debug][sdk=*][arch=*] = YES
```

这就导致了配置和实际生效的结果不一致，本来的意愿是值针对"Debug"环境触发：

```
|-- VALUE
    |--   Debug     <YOUR DEBUG VALUE>
    |-- Release     <YOUR RELEASE VALUE>
```

而实际上，Xcode会创建一个如下的subset：

```
|-- VALUE
    |--   Debug                     <EMPTY OR DEFAULT VALUE>
        |-- Any SDK OR Any Arch     <YOUR DEBUG VALUE>
    |-- Release                     <EMPTY OR DEFAULT VALUE>
        |-- Any SDK OR Any Arch     <YOUR RELEASE VALUE>
```

所以不建议采用该条件方法。


### 5.4 Variant

Variant的判断条件主要基于`$(CURRENT_VARIANT)`。而`$(CURRENT_VARIANT)`的build setting来自于[\$(BUILD_VARIANTS)](https://pewpewthespells.com/blog/buildsettings.html#build_variants)。

该条件不应该被使用。

### 5.5 Dialect

虽然是条件，但是不清楚如何使用。

## 6.变量的替换（使用）

变量可以通过索引用来给其他变量赋值，主要有两种方式，比如变量`Foo`可以通过以下方式索引：

```
$(FOO)
${FOO}
```

举例：
```
HELLO = hello
WORLD = world
FOO = $(HELLO) ${WORLD} // The value of FOO is "hello world"
```

复杂的变量替换可以实现嵌套替换，比如如下代码，Xcode会优先解析`$(WRAPPER_EXTENSION)` (是`app`/`xctest`)，然后便可以解析`$(CURRENT_PROJECT_VERSION_app)`或者 `$(CURRENT_PROJECT_VERSION_xctest)`变量。

```
CURRENT_PROJECT_VERSION_app = 15.3.9 // Application version number
CURRENT_PROJECT_VERSION_xctest = 1.0.0 // Unit Test version number

CURRENT_PROJECT_VERSION = $(CURRENT_PROJECT_VERSION_$(WRAPPER_EXTENSION))
```

如果`$(WRAPPER_EXTENSION)`的值不是`app`/`xctest`，则变量`$(CURRENT_PROJECT_VERSION_)`无法解析，从而导致`CURRENT_PROJECT_VERSION`声明失败（无值）。

> **NOTE:** There is a way to work around the limitations of invalid character names. If you edit the project.pbxproj file in the Xcode project file and add new values to the relevant XCBuildConfiguration objects by enclosing the name in double quotes, the variables will register as valid and be displayed under the "User-Defined" settings section in the Xcode editor. While these settings are visible and can be used to substitute values elsewhere in the project or in the xcconfig files this is not supported behavior. Setting with names that contain invalid characters will not get properly exported to be used in other parts of the build system.

## 7. Build Setting的继承(Inheritance) 

> 以下说明可能不准确，因为是通过逆向工程Xcode得到的。

Xcode是通过“levels（层级）”来组合build setting，每个level中build setting可以从上一个level中继承`变量`。

`继承`按以下顺序执行（底下的level可以继承上面的level）：

 - Platform defaults 
 - Project file 
 - xcconfig file for the Project file
 - Target 
 - xcconfig file for the Target

按一下顺序执行赋值（最底下的变量赋值会override上面定义的变量的值）：

- Platform defaults
- xcconfig for the Project file
- Project file
- xcconfig for the Target
- Target

继承和赋值的顺序是非常重要的，不然会产生奇怪的bug。例如，在Target中配置`PRODUCT_NAME`为`MyApp`，然后又在xcconfig文件中配置如下

```
//
// Config.xcconfig
//

PRODUCT_NAME = testing

// `PRODUCT_NAME_ORIGINAL`的值为 "MyApp"，因为Target赋值优于xcconfig
PRODUCT_NAME_ORIGINAL = $(PRODUCT_NAME)

// ...

FOO_MyApp = MyAppsName
FOO_testing = MyAppsNewName
// "PRODUCT_NAME"也是 "MyApp"，BAR 是“$(FOO_MyApp)”
BAR = $(FOO_$(PRODUCT_NAME))
```

`继承(Inheritance)`只能在levels之间进行，在同一level上执行的变量赋值将覆盖前面的赋值。不能在xcconfig中使用`$(inherited)`来继承导入的xcconfig中的变量（因为他们是同一个level）。要使用该值，必须使用他自己的名称，并在当前赋值中引用这些变量名称。


## 参考

【1】[The Unofficial Guide to xcconfig files](https://pewpewthespells.com/blog/xcconfig_guide.html)

