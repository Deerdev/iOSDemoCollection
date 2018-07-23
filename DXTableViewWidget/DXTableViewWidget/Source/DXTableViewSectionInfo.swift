//
//  DXTableViewSectionInfo.swift
//  DXTableViewWidget
//
//  Created by deer on 2018/7/20.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class DXTableViewSectionInfo: DXTableViewValueInfo {
    private lazy var cellInfos = [DXTableViewCellInfo]()
    /// section高度
    var headerHeight: CGFloat = 20
    var footerHeight: CGFloat = 0.01

    private override init() {
        super.init()
    }

    // MARK: - init
    class func sectionInfoDefault(headerHeight: CGFloat = 0.01) -> DXTableViewSectionInfo {
        let info = DXTableViewSectionInfo()
        info.headerHeight = headerHeight
        return info
    }

    class func sectionInfoHeader(with title: String) -> DXTableViewSectionInfo {
        return self.sectionInfoWith(headerTitle: title, headerView: nil, footerTitle: nil, footerView: nil)
    }

    class func sectionInfoHeader(with view: UIView) -> DXTableViewSectionInfo {
        return self.sectionInfoWith(headerTitle: nil, headerView: view, footerTitle: nil, footerView: nil)
    }

    class func sectionInfoFooter(with title: String) -> DXTableViewSectionInfo {
        return self.sectionInfoWith(headerTitle: nil, headerView: nil, footerTitle: title, footerView: nil)
    }

    class func sectionInfoFooter(with view: UIView) -> DXTableViewSectionInfo {
        return self.sectionInfoWith(headerTitle: nil, headerView: nil, footerTitle: nil, footerView: view)
    }

    class func sectionInfoWith(headerTitle: String?, headerView: UIView?, footerTitle: String?, footerView: UIView?) -> DXTableViewSectionInfo {
        let info = DXTableViewSectionInfo()
        if let title = headerTitle {
            info.add(value: title, for: "headerTitle")
            info.headerHeight = -1
        }
        if let view = headerView {
            info.add(value: view, for: "header")
            info.headerHeight = view.frame.height
        }
        if let title = footerTitle {
            info.add(value: title, for: "footerTitle")
            info.footerHeight = -1
        }
        if let view = footerView {
            info.add(value: view, for: "footer")
            info.footerHeight = view.frame.height
        }
        return info
    }

    // MARK: - cell opertation
    func cellCount() -> Int {
        return cellInfos.count
    }

    func add(_ cellInfo: DXTableViewCellInfo) {
        cellInfos.append(cellInfo)
    }

    func insert(_ cellInfo: DXTableViewCellInfo, at index: Int) {
        cellInfos.insert(cellInfo, at: index)
    }

    func replace(_ cellInfo: DXTableViewCellInfo, at index: Int) {
        if index < cellInfos.count {
            cellInfos[index] = cellInfo
        }
    }

    func removeAll() {
        cellInfos.removeAll()
    }

    func removeCell(at index: Int) {
        cellInfos.remove(at: index)
    }

    func cell(at index: Int) -> DXTableViewCellInfo? {
        return index < cellInfos.count ? cellInfos[index] : nil
    }
}
