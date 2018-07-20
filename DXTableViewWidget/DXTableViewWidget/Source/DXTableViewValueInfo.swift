//
//  DXTableViewValueInfo.swift
//  DXTableViewWidget
//
//  Created by deer on 2018/7/20.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class DXTableViewValueInfo: NSObject {
    private lazy var dict = [String: Any]()

    func add(value: Any?, for key: String?) {
        if let value = value, let key = key {
            dict[key] = value
        }
    }

    func getValueFor(key: String?) -> Any? {
        if let key = key {
            return dict[key]
        }
        return nil
    }
}
