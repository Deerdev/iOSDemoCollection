//
//  DeviceInfo.swift
//  YYDeviceScanning
//
//  Created by daoquan on 2018/2/24.
//  Copyright © 2018年 deerdev. All rights reserved.
//

import UIKit

class DeviceInfo: NSObject {
    var productId = ""
    var owner = ""
    var sn = ""
    var mac = ""
    var dbId: Int?

    convenience init(_ id: String, _ owner: String, _ sn: String, _ mac: String, _ dbId: Int?) {
        self.init()
        self.productId = id
        self.owner = owner
        self.sn = sn
        self.mac = mac
        self.dbId = dbId
    }
}
