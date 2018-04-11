//
//  NetWorkToolForMultiTask.swift
//  BackgroundDownload
//
//  Created by deer on 2018/4/11.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

let backIdentifier2 = "com.deerdev.background2"


class NetWorkToolForMultiTask: NSObject {
    static let shared: NetWorkToolForMultiTask = NetWorkToolForMultiTask()
    var downloadWaitingQueue = [URLSessionTask]()
    var downloadCompleteHandler = [String: DownloadCompleteBlock]()
    /**
     设置下载任务的个数，最多支持3个下载任务同时进行。
     NSURLSession最多支持5个任务同时进行
     但是5个任务，在某些情况下，部分任务会出现等待的状态，所有设置最多支持3个
     */
    var maxTaskCount = 1

    lazy var backgroundSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: backIdentifier)
        //是否允许蜂窝访问
        config.allowsCellularAccess = false
        //是否在后台启动app
        config.sessionSendsLaunchEvents = true
        let backgroundSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return backgroundSession
    }()

    // MARK: - backgroud download
    func startBackDownload(URLStr: String) {
        let request = URLRequest(url: URL(string: URLStr)!)

        // 若有多个任务，需要一次性添加，否则一个任务继续后，不能再添加下一个任务
        // 若使用block的方法，在后台，block时不能被调用的，只能使用代理方法
        let downloadTask = backgroundSession.downloadTask(with: request)

        let currentTask = backgroundSession.value(forKey: "tasks") as! [Int: URLSessionTask]
        let cout = currentTask.keys.count
        // 刚刚添加的任务也在里面（+1）
        if cout >= maxTaskCount + 1 {
            // 加入等待队列
            print("add to waiting")
            downloadWaitingQueue.append(downloadTask)
        } else {
            // 开始任务
            downloadTask.resume()
        }
    }

    /// 一次后台下载中方法的执行时序为：
    /// ->a. handleEventsForBackgroundURLSession
    /// ->b. URLSession: downloadTask: didFinishDownloadingToURL
    /// ->c. URLSessionDidFinishEventsForBackgroundURLSession
    func handlerCompleteBlock(_ identifier: String) {
        if let block = downloadCompleteHandler[identifier] {
            downloadCompleteHandler.removeValue(forKey: identifier)
            block()
        }
        /*
         根据苹果员工的回复（https://forums.developer.apple.com/thread/69825），这里苹果需要用这个block实现两个功能:
         a. 系统后台生成快照
         b. 释放阻止应用挂起的断言（让应用继续在后台运行，节约系统资源）

         The system does two things in that completion handler:
         It snapshots your UI for the benefit of the multitasking switcher
         It releases the assertion that was preventing your app from being suspended
         */
    }

    /// 添加（Appdelegate）handleEventsForBackgroundURLSession返回的completionHandler
    func addDownloadCompleteBlock(_ block: @escaping DownloadCompleteBlock, _ identifier: String) {
        downloadCompleteHandler[identifier] = block
    }
}

extension NetWorkToolForMultiTask: URLSessionDelegate {
    /// 实现URLSessionDidFinishEventsForBackgroundURLSession，
    /// 待所有数据处理完成，UI刷新之后在该方法中在调用之前保存的completionHandler()。
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        // 3-最后调用
        print("3-background task finished")
        if let identifier = session.configuration.identifier, !identifier.isEmpty {
            handlerCompleteBlock(identifier)
        }
    }
}

extension NetWorkToolForMultiTask: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("2.1-session task(\(task)) finished")

        if let error = error {
            // 失败时，error时有值的，并且可以获得resumeData

            // check if resume data are available,
            var resumeData = (error as NSError).userInfo[NSURLSessionDownloadTaskResumeData] as? Data
            // 通过保存该resumeData，获取断点的NSURLSessionTask，调用resume恢复下载
        } else {
            // 下载成功，发送通知
        }
    }
}

extension NetWorkToolForMultiTask: URLSessionDownloadDelegate {
    // 2-background session 可以调用该代理方法
    /// 下载完成时调用
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("2- Download task(\(downloadTask)) finished Delegate, location:(\(location)")

        // 保存下载好的文件
        guard let documentPath = PNFileUtil.getPathInDocumentsDir(by: "Downloads", createIfNotExist: true) else { return }
        let fileSavePath = URL(fileURLWithPath: documentPath).appendingPathComponent("\(downloadTask.description)")
        debugPrint("保存路径：\(fileSavePath)")
        if let _ = try? FileManager.default.moveItem(at: location, to: fileSavePath) {
            print("cut file")
        }

        // 继续下一个任务
        if downloadWaitingQueue.count > 0 {
            let task = downloadWaitingQueue[0]
            downloadWaitingQueue.remove(at: 0)
            print("--------------------------")
            print("- next task begin\(task) after task(\(downloadTask))")
            task.resume()
        }
    }

    /// 续传的回调
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        //
    }

    /// 获取下载进度
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // 更新下载进度
        print("\(totalBytesWritten)/\(totalBytesExpectedToWrite)")
    }
}
