//
//  NetWorkTool.swift
//  BackgroundDownload
//
//  Created by deer on 2018/4/10.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

let backIdentifier = "com.deerdev.background"

typealias DownloadCompleteBlock = () -> ()

class NetWorkToolForOneTask: NSObject {
    static let shared: NetWorkToolForOneTask = NetWorkToolForOneTask()
    var downloadCompleteHandler = [String: DownloadCompleteBlock]()
    var currentTask: URLSessionDownloadTask?
    var resumeData: Data?
    var progressBlock: ((String) -> Void)?

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

        self.currentTask = downloadTask
        downloadTask.resume()
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

    // MARK: - 暂停任务 方法1
    func pauseDownloadTask1() {
        self.currentTask?.cancel(byProducingResumeData: { [weak self] (resumeData) in
            self?.resumeData = resumeData
        })

        /* 【一种暂停思路:https://blog.csdn.net/jelly_1992/article/details/76512425】
         清空下载任务，暂停后，把会话session和下载任务task都清空，下次继续任务(开启)时，走重新创建的方法。
         */
/*
        // 1-取消任务
        downloadTask.cancel(byProducingResumeData: {(_ resumeData: Data?) -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                if resumeData != nil {
                    // 2-记录续传数据
                    weakSelf.resumeData = resumeData
                    // 3-清空下载任务，暂停后，把会话session和下载任务task都清空，下次开启时，重新创建。
                    weakSelf.session.finishTasksAndInvalidate()
                    weakSelf.session = nil
                    weakSelf.downloadTask = nil
                    // 4-将续传数据写入文件中
                    if !(resumeData?.write(toFile: weakSelf.resumeDataPath(weakSelf.currentFileModel.lessonId), atomically: true) ?? false) {
                        AppLog("resumeData写入失败")
                    }
                } else {
                    AppLog("暂停错误")
                }
            })
        })
*/
    }

    // MARK: - 继续任务 方法1
    func continueTask1() {
        if let resumeData = self.resumeData {
            if let osVersion = Float(UIDevice.current.systemVersion) {
                if osVersion > 10, osVersion < 10.4 {
                    // iOS系统bug，需要处理resumeData
                    self.currentTask = backgroundSession.downloadTask(withCorrectResumeData: resumeData)
                } else {
                    self.currentTask = backgroundSession.downloadTask(withResumeData: resumeData)
                }
                self.currentTask?.resume()
                self.resumeData = nil
            }
        }
    }

    // MARK: - 暂停任务 方法2
    func pauseDownloadTask2() {
        self.currentTask?.suspend()
    }

    // MARK: - 继续任务 方法2
    func continueTask2() {
        self.currentTask?.resume()
    }

    /// 校验resumeData的合法性
    func isValideResumeData(_ resumeData: Data?) -> Bool {
        if resumeData == nil || (resumeData?.count ?? 0) == 0 {
            return false
        }
        return true
    }
}

extension NetWorkToolForOneTask: URLSessionDelegate {
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

extension NetWorkToolForOneTask: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("2.1-session task(\(task)) finished")

        if let error = error {
            // MARK: - 暂停任务 方法3（通过error获取resumedata）

            // 失败时，error时有值的，并且可以获得resumeData
            let resumeData = (error as NSError).userInfo[NSURLSessionDownloadTaskResumeData] as? Data
            // check if resume data are available
            if var resumeData = resumeData, isValideResumeData(resumeData) {
                if let osVersion = Float(UIDevice.current.systemVersion) {
                    if osVersion >= 11.1, osVersion < 11.2 {
                        //修正iOS11 多次暂停继续 文件大小不对的问题
                        resumeData = URLSession.cleanResumeData(resumeData)
                    }
                }
                // 通过保存该resumeData，之后获取出错的NSURLSessionTask，调用resume恢复下载
                // ......
                self.resumeData = resumeData
            }
        } else {
            // 下载成功，发送通知
        }
    }
}

extension NetWorkToolForOneTask: URLSessionDownloadDelegate {
    // 2-background session 可以调用该代理方法
    /// 下载完成时调用
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("2- Download task(\(downloadTask)) finished Delegate")

        // 保存下载好的文件
        guard let documentPath = PNFileUtil.getPathInDocumentsDir(by: "Downloads", createIfNotExist: true) else { return }
        let fileSavePath = URL(fileURLWithPath: documentPath).appendingPathComponent("\(downloadTask.description)")
        debugPrint("保存路径：\(fileSavePath)")
        if let _ = try? FileManager.default.moveItem(at: location, to: fileSavePath) {
            print("cut file")
        }
    }

    /// 续传的回调
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        //
    }

    /// 获取下载进度
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // 更新下载进度
        let progressStr = "\(totalBytesWritten)/\(totalBytesExpectedToWrite)"
        print(progressStr)
        self.progressBlock?(progressStr)

        /* 【一种保存思路:https://blog.csdn.net/jelly_1992/article/details/76512425】
           每下载5%的大小时我们就手动保存一下数据，具体就是暂停一下当前任务，然后再继续下载。
           不过只适用于APP在前台下载时，因为APP进入后台就不走代码了，所以我们在代码中实现的断点续传也就不能实现了。
        */
/*
        // 1-取消任务
        downloadTask.cancel(byProducingResumeData: {(_ resumeData: Data?) -> Void in
            //2-保存数据
            if !(resumeData?.write(toFile: self.resumeDataPath(self.currentFileModel.lessonId), atomically: true) ?? false) {
                AppLog("resumeData写入失败")
            }
            self.resumeData = resumeData

            //3-暂停后，继续下载
            if self.resumeData != nil {
                self.downloadTask = nil
                if let aData = self.resumeData {
                    self.downloadTask = self.session.downloadTask(withResumeData: aData)
                }
                self.downloadTask.resume()
            }

        })
*/
    }
}
