//
//  AppDelegate.swift
//  BackgroundDownload
//
//  Created by deer on 2018/4/10.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    /*
     在appDelegate中实现handleEventsForBackgroundURLSession，要注意的是，需要在handleEventsForBackgroundURLSession中必须重新建立一个后台 session 的参照（可以用之前dispatch_once创建的对象），否则 NSURLSessionDownloadDelegate 和 NSURLSessionDelegate 方法会因为没有 对 session 的 delegate 设置而不会被调用。
     然后保存completionHandler()
     */
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        // 1-通过重新创建，获取background session
        print("1-appdelegate handle background session")
        let config = URLSessionConfiguration.background(withIdentifier: backIdentifier)
        let session = URLSession(configuration: config, delegate: NetWorkToolForOneTask.shared, delegateQueue: nil)

        // save completionHandler
        NetWorkToolForOneTask.shared.addDownloadCompleteBlock(completionHandler, identifier)
    }

}

