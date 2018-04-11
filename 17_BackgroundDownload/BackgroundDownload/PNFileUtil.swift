//
//  PNFileUtil.swift
//  PhiNAS
//
//  Created by deer on 2018/3/30.
//  Copyright © 2018年 phicomm. All rights reserved.
//

import UIKit

/// 文件工具类
class PNFileUtil: NSObject {

    /// 获取文件大小
    ///
    /// - Parameter path: 文件路径
    class func fileSize(forPath path: String?) -> UInt64 {
        guard let path = path else { return 0 }

        var fileSize: UInt64 = 0
        let fileManager = FileManager()
        if fileManager.fileExists(atPath: path) {
            if let fileDict = try? fileManager.attributesOfItem(atPath: path) {
                fileSize = (fileDict[FileAttributeKey.size] as? UInt64) ?? 0
            }
        }
        return fileSize
    }

    /// 获取指定文件的临时文件存放路径
    ///
    /// - Parameters:
    ///   - path: 文件路径
    ///   - saveIn: 文件保存子路径
    /// - Returns: 临时文件路径
    class func tempPath(for path: String?, saveIn: String?) -> String? {
        guard let path = path, let saveIn = saveIn else { return nil }
        var tempFilePath: String?
        let tempFileName = URL(fileURLWithPath: path).path
        if let cachePath = PNFileUtil.getPathInCacheDir(by: saveIn, createIfNotExist: true) {
            tempFilePath = cachePath + tempFileName
        }
        return tempFilePath
    }

    /// 获取Documents文件夹内子文件夹的路径
    ///
    /// - Parameters:
    ///   - subFolder: 子文件夹路径
    ///   - needCeate: 如果不存在，是否需要创建
    class func getPathInDocumentsDir(by subFolder: String?, createIfNotExist needCeate: Bool) -> String? {
        guard let subFolder = subFolder else { return nil }

        var subPath: String?
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = dir.appendingPathComponent(subFolder)

        if !PNFileUtil.fileExists(atPath: path.path) && needCeate {
            do {
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
                subPath = path.path
            } catch {
                print("创建\(subFolder)失败, Error=\(error)")
            }
        } else {
            subPath = path.path
        }

        return subPath
    }

    /// 获取Cache文件夹内子文件夹的路径
    ///
    /// - Parameters:
    ///   - subFolder: 子文件夹路径
    ///   - needCeate: 如果不存在，是否需要创建
    class func getPathInCacheDir(by subFolder: String?, createIfNotExist needCeate: Bool) -> String? {
        guard let subFolder = subFolder else { return nil }

        var subPath: String?
        let dir = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Cache")
        let path = dir.appendingPathComponent(subFolder)
        if !PNFileUtil.fileExists(atPath: path.path) && needCeate {
            do {
                try FileManager().createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
                subPath = path.path
            } catch {
                print("创建\(subFolder)失败, Error=\(error)")
            }
        } else {
            subPath = path.path
        }
        return subPath
    }

    /// 判断指定路径下的文件是否存在
    class func fileExists(atPath path: String?) -> Bool {
        guard let path = path else { return false }
        let fileManager = FileManager.default
        let isExist = fileManager.fileExists(atPath: path)
        return isExist
    }

    /// 删除指定路径下的文件
    class func deleteFile(atPath path: String?) -> Bool {
        guard let path = path else { return false }

        let fileManager = FileManager.default
        var result = false
        if PNFileUtil.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
                result = true
            } catch {
                print("removeItemAtPath:\(path) 失败,error = \(error)")
            }
        } else {
            result = true
        }

        return result
    }

    /// 将指定文件剪切到指定位置
    ///
    /// - Parameters:
    ///   - srcPath: 源文件地址
    ///   - dstPath: 目标文件地址
    class func cutFile(atPath srcPath: String?, toPath dstPath: String?) -> Bool {
        guard let srcPath = srcPath, let dstPath = dstPath else { return false }

        let fileManager = FileManager.default
        var result = false
        if PNFileUtil.deleteFile(atPath: dstPath) {
            if PNFileUtil.fileExists(atPath: srcPath) {
                do {
                    try fileManager.moveItem(atPath: srcPath, toPath: dstPath)
                    result = true
                } catch {
                    print("moveItemFromePath:\(srcPath) to \(dstPath) 失败,error = \(error)")
                }
            }
        }
        return result
    }

    /// 返回文件大小
    class func calculateFileSize(inUnit contentLength: UInt64) -> Float {
        let length = Double(contentLength)

        if length >= pow(1024, 3) {
            return Float(length / pow(1024, 3))
        } else if length >= pow(1024, 2) {
            return Float(length / pow(1024, 2))
        } else if length >= pow(1024, 1) {
            return Float(length / pow(1024, 1))
        } else {
            return Float(length)
        }
    }

    /// 返回文件大小的单位
    class func calculateUnit(_ contentLength: UInt64) -> String? {
        let size = Double(contentLength)
        var sizeText: String?
        if size >= pow(1024, 3) {
            // size >= 1GB
            sizeText = String(format: "%.2fG", size / pow(1024, 3))
        } else if size >= pow(1024, 2) {
            // 1GB > size >= 1MB
            sizeText = String(format: "%.2fM", size / pow(1024, 2))
        } else if size >= pow(1024, 1) {
            // 1MB > size >= 1KB
            sizeText = String(format: "%.2fK", size / pow(1024, 1))
        } else {
            // 1KB > size
            sizeText = "\(size)B"
        }
        return sizeText
    }
}
