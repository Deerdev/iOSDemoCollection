//: Playground - noun: a place where people can play

//: 参考链接
//: - [iOS使用NSURLSession进行下载（包括后台下载，断点下载）](https://www.jianshu.com/p/1211cf99dfc3)
//: - [iOS后台下载及管理库](http://www.onezen.cc/2017/09/18/iosdev/bgdownload.html)
//: - [iOS后台上传](http://www.onezen.cc/2018/01/09/iosdev/iosbgup.html)
//: - [iOS NSURLSession后台下载多个任务，支持断点续传](https://blog.csdn.net/jelly_1992/article/details/76512425)

/*
 一些参考文档：

 https://my.oschina.net/iOSliuhui/blog/469276  断点下载流程讲解
 http://www.cocoachina.com/ios/20160503/16053.html  断点续传方案 ??? 不断保存？方案不可取！ 程序被杀时主动保存！这里的ios应该为小写，被自动格式化成大写了
 https://code.tutsplus.com/tutorials/ios-7-sdk-background-transfer-service--mobile-20595 后台传输服务
 http://www.jianshu.com/p/1211cf99dfc3 下载相关，BackgroundDownloadDemo作者的分享
 苹果论坛相关讨论
 https://forums.developer.apple.com/thread/14854
 https://forums.developer.apple.com/thread/69825\

 提示：当使用 Xcode 调试，当 app 在后台时，调试器实际上会阻止其被系统终止运行，所以我的策略是打开“Wait for Launch”选项（Edit Scheme>Run>Info>Wait for executable to be launched），然后手动启动 app 和下载，在启动调试器前，退出 app 到后台。
 */

import UIKit

var str = "Hello, playground"
