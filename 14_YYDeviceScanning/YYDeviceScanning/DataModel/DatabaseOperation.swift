//
//  DatabaseOperation.swift
//  YYDeviceScanning
//
//  Created by daoquan on 2018/2/24.
//  Copyright © 2018年 deerdev. All rights reserved.
//

import UIKit
import FMDB

class DBOperation: NSObject {
    let dbFileName = "yydevices.sqlite"
//    let filePathUrl: URL
    var databasePath = ""
    var database: FMDatabase!

    let k_deviceId = "id"
    let k_productId = "productid"
    let k_owner = "owner"
    let k_sn = "sn"
    let k_mac = "mac"


    static let shared: DBOperation = DBOperation()

    private override init() {
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        databasePath = documentsDirectory.appending("/\(dbFileName)")

//        let manager = FileManager.default
//        let urlPaths = manager.urls(for: .documentDirectory, in: .userDomainMask)
//        var fileUrl = URL(fileURLWithPath: "")
//        if let urlForDoc = urlPaths.first {
//            fileUrl = urlForDoc.appendingPathComponent(dbFileName)
//        }
//
//        self.filePathUrl = fileUrl
        super.init()
    }

    // MARK: - 创建数据库
    func creatDB() -> Bool {
        var result = false
        // 1-判断文件是否存在
        let manager = FileManager.default
        if manager.fileExists(atPath: databasePath) {
            return true
        }

        // 2-创建数据库
        let db = FMDatabase(path: databasePath)
        // 3-打开数据库
        if db.open() {
            // 4-建表
            let sql = """
            CREATE TABLE IF NOT EXISTS DeviceInfo (\(k_deviceId) INTEGER PRIMARY KEY AUTOINCREMENT not null, \(k_productId) TEXT not null, \(k_owner) TEXT not null, \(k_sn) TEXT not null, \(k_mac) TEXT not null);
            """
            do {
                try db.executeUpdate(sql, values: nil)
                result = true
            } catch {
                print("Could not create table.")
                print(error.localizedDescription)
            }

            db.close()
        }
        return result
    }

    func deleteDatabase() -> Bool {
        var result = false
        do {
            try FileManager.default.removeItem(atPath: databasePath)
            result = true
        } catch {
            print("Could not delete database file")
        }
        return result
    }

    func openDatabase() -> Bool {
        if database == nil {
            if FileManager.default.fileExists(atPath: databasePath) {
                database = FMDatabase(path: databasePath)
            }
        }

        if database != nil {
            if database.open() {
                return true
            }
        }

        return false
    }

    func insertInfoToDB(_ info: DeviceInfo) -> Bool {
        var result = false
        if openDatabase() {
            let query = """
            insert into DeviceInfo (\(k_deviceId), \(k_productId), \(k_owner), \(k_sn), \(k_mac)) values (null, '\(info.productId)', '\(info.owner)', '\(info.sn)', '\(info.mac)');
            """

            if !database.executeStatements(query) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            } else {
                result = true
            }
            database.close()
        }
        return result
    }

    func loadInfoFromDB() -> [DeviceInfo]? {
        var devices: [DeviceInfo]?
        if openDatabase() {
            let query = """
            select * from DeviceInfo order by \(k_deviceId) asc
            """
            do {
                let results = try database.executeQuery(query, values: nil)
                var deviceList = [DeviceInfo]()
                while results.next() {
                    if let productId = results.string(forColumn: k_productId),
                        let owner = results.string(forColumn: k_owner),
                        let sn = results.string(forColumn: k_sn),
                        let mac = results.string(forColumn: k_mac) {
                        let dbId = Int(results.int(forColumn: k_deviceId))
                        let device = DeviceInfo.init(productId, owner, sn, mac, dbId)
                        deviceList.append(device)
                    }
                }

                if !deviceList.isEmpty {
                    devices = deviceList
                }
            } catch {
                print(error.localizedDescription)
            }
            database.close()
        }

        return devices
    }

    func updateInfo(_ info: DeviceInfo) -> Bool {
        var result = false
        guard let dbId = info.dbId else {
            return result
        }
        if openDatabase() {
            let query = """
            update DeviceInfo set \(k_productId)=?, \(k_owner)=?, \(k_sn)=?, \(k_mac)=? where \(k_deviceId)=?
            """
            do {
                try database.executeUpdate(query, values: [info.productId, info.owner, info.sn, info.mac, dbId])
                result = true
            } catch {
                print(error.localizedDescription)
            }
            database.close()
        }
        return result
    }

    func deleteIndo(_ info: DeviceInfo) -> Bool {
        var result = false
        guard let dbId = info.dbId else {
            return result
        }
        if openDatabase() {
            let query = """
            delete from DeviceInfo where \(k_deviceId)=?
            """
            do {
                try database.executeUpdate(query, values: [dbId])
                result = true
            } catch {
                print(error.localizedDescription)
            }

            database.close()
        }
        return result
    }
    // MARK: - 导出数据库

    // MARK: - 导入数据库

}
