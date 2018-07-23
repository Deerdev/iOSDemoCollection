//
//  DXTableViewCellInfo.swift
//  DXTableViewWidget
//
//  Created by deer on 2018/7/20.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class DXTableViewCellInfo: DXTableViewValueInfo {
    var cellHeight: CGFloat = 44
    var indexPath: IndexPath?
    var accessoryType: UITableViewCell.AccessoryType = .none
    var selectionStyle: UITableViewCell.SelectionStyle = .default
    var cellStyle: UITableViewCell.CellStyle = .value1
    var target: NSObject?
    var selector: Selector?
    var cellTextAlign: NSTextAlignment = .left
    weak var targetOfSwitch: NSObject?

    // cell需要额外执行的操作
    var extraSel: Selector?
    weak var extraTarget: NSObject?

    private override init() {
        super.init()
    }

    // MARK: - cell init
    /// 没有点击事件（标题+右边字）
    class func normalCellFor(title: String, rightValue: String) -> DXTableViewCellInfo {
        let info = DXTableViewCellInfo()
        info.selectionStyle = .none
        info.add(value: title, for: "title")
        info.add(value: rightValue, for: "rightValue")
        return info
    }

    /// 没有点击事件（图片 标题+右边字）
    class func normalCellFor(title: String, rightValue: String, imageName: String) -> DXTableViewCellInfo {
        let info = self.normalCellFor(title: title, rightValue: rightValue)
        info.add(value: imageName, for: "imageName")
        return info
    }

    /// 有点击事件（标题+右边字）
    class func normalCellFor(selector: Selector, target: NSObject, title: String, rightValue: String, accessoryType: UITableViewCell.AccessoryType) -> DXTableViewCellInfo {
        let info = self.normalCellFor(title: title, rightValue: rightValue)
        info.selectionStyle = .default
        info.target = target
        info.selector = selector
        info.accessoryType = accessoryType
        return info
    }

    /// 有点击事件（图片 标题+右边字）
    class func normalCellFor(selector: Selector, target: NSObject, title: String, rightValue: String, accessoryType: UITableViewCell.AccessoryType, imageName: String) -> DXTableViewCellInfo {
        let info = self.normalCellFor(selector: selector, target: target, title: title, rightValue: rightValue, accessoryType: accessoryType)
        info.add(value: imageName, for: "imageName")
        return info
    }

    /// 有点击事件（标题居中）
    class func centerCellFor(selector: Selector, target: NSObject, title: String) -> DXTableViewCellInfo {
        let info = DXTableViewCellInfo()
        // 居中，cell的类型必须是 default
        info.cellStyle = .default
        info.add(value: title, for: "title")
        info.target = target
        info.selector = selector
        info.extraSel = #selector(centerTextAlignOf(cell:))
        info.extraTarget = info
        return info
    }

    /// 有switch（无点击事件）
    class func switchCellFor(title: String, isOn: Bool) -> DXTableViewCellInfo {
        let info = DXTableViewCellInfo()
        info.extraSel = #selector(addSwitchTo(cell:))
        info.extraTarget = info
        info.selectionStyle = .none
        info.add(value: isOn, for: "on")
        info.add(value: title, for: "title")
        return info
    }

    /// 有switch（有点击事件）
    class func switchCellFor(selector: Selector, target: NSObject, title: String, isOn: Bool) -> DXTableViewCellInfo {
        let info = self.switchCellFor(title: title, isOn: isOn)
        info.targetOfSwitch = target
        info.selector = selector
        return info
    }

    /// 自定义
    class func cellFor(selector: Selector?, target: NSObject?, extraSel: Selector?, extraTarget: NSObject?, height: CGFloat, dict: [String: Any], accessoryType: UITableViewCell.AccessoryType, selectionStyle: UITableViewCell.SelectionStyle) -> DXTableViewCellInfo {
        let info = DXTableViewCellInfo()
        info.selector = selector
        info.target = target
        info.extraSel = extraSel
        info.extraTarget = extraTarget
        info.cellHeight = height
        info.accessoryType = accessoryType
        info.selectionStyle = selectionStyle
        for (key, value) in dict {
            info.add(value: value, for: key)
        }
        return info
    }
}

// MARK: - selector
extension DXTableViewCellInfo {
    /// cell的标题文字居中
    @objc func centerTextAlignOf(cell: UITableViewCell) {
        cell.textLabel?.textAlignment = .center
    }

    /// 添加switch到cell
    @objc func addSwitchTo(cell: UITableViewCell) {
        let isOn = self.getValueFor(key: "on") as? Bool ?? false
        let switcher = UISwitch()
        switcher.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        switcher.isOn = isOn
        cell.accessoryView = switcher
    }

    /// switch点击事件(传递给外面的接收者)
    @objc func switchValueChanged(_ sender: UISwitch) {
        self.add(value: sender.isOn, for: "on")
        if let target = targetOfSwitch, let sel = selector, let indexPath = indexPath, target.responds(to: sel) {
            target.perform(sel, with: self, with: indexPath)
        }
    }
}
