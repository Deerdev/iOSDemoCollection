//
//  DXTableViewInfo.swift
//  DXTableViewWidget
//
//  Created by deer on 2018/7/20.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class DXTableViewInfo: NSObject {
    private var tableView: UITableView!
    private lazy var sectionInfos = [DXTableViewSectionInfo]()

    init(frame: CGRect, style: UITableView.Style) {
        super.init()
        tableView = DXTableView(frame: frame, style: style)
        tableView.delegate = self
        tableView.dataSource = self
    }

    func getTableView() -> UITableView {
        return tableView
    }


    // MARK: - section operation
    func sectionCount() -> Int {
        return sectionInfos.count
    }

    func sectionInfo(at index: Int) -> DXTableViewSectionInfo? {
        guard index < sectionInfos.count else { return nil }
        return sectionInfos[index]
    }

    func addSection(_ sectionInfo: DXTableViewSectionInfo) {
        sectionInfos.append(sectionInfo)
    }

    func insertSection(_ sectionInfo: DXTableViewSectionInfo, at index: Int) {
        sectionInfos.insert(sectionInfo, at: index)
    }

    func replaceSection(_ sectionInfo: DXTableViewSectionInfo, at index: Int) {
        if index < sectionInfos.count {
            sectionInfos[index] = sectionInfo
        }
    }

    func removeSection(at index: Int) {
        sectionInfos.remove(at: index)
    }

    func removeAllSection() {
        sectionInfos.removeAll()
    }

    // MARK: - cell operation
    func insertCell(_ cellInfo: DXTableViewCellInfo, at indexPath: IndexPath) {
        guard indexPath.section < sectionInfos.count  else { return }
        let section = sectionInfos[indexPath.section]
        section.insert(cellInfo, at: indexPath.row)
    }

    func replaceCell(_ cellInfo: DXTableViewCellInfo, at indexPath: IndexPath) {
        guard indexPath.section < sectionInfos.count  else { return }
        let section = sectionInfos[indexPath.section]
        section.replace(cellInfo, at: indexPath.row)
    }

    func replaceCell(at indexPath: IndexPath) {
        guard indexPath.section < sectionInfos.count  else { return }
        let section = sectionInfos[indexPath.section]
        section.removeCell(at: indexPath.row)
    }

}

extension DXTableViewInfo: UITableViewDataSource {
    //MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionInfos.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < sectionInfos.count else { return 0 }
        return sectionInfos[section].cellCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section < sectionInfos.count,
            let cellInfo = sectionInfos[indexPath.section].cell(at: indexPath.row) else {
                return UITableViewCell()
        }

        let identifier = "DXTableView_\(indexPath.section)_\(indexPath.row)"
        var cell: DXTableViewCell
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DXTableViewCell {
            cell = reuseCell
        } else {
            cell = DXTableViewCell(style: cellInfo.cellStyle, reuseIdentifier: identifier)
        }

        // 有额外的操作，先执行一下
        if let target = cellInfo.extraTarget, let sel = cellInfo.extraSel, target.responds(to: sel) {
            target.perform(sel, with: cell, with: cellInfo)
        }

        cell.accessoryType = cellInfo.accessoryType
        cell.selectionStyle = cellInfo.selectionStyle
        cell.textLabel?.text = cellInfo.getValueFor(key: "title") as? String
        cell.detailTextLabel?.text = cellInfo.getValueFor(key: "rightValue") as? String
        cellInfo.indexPath = indexPath

        if let imageName = cellInfo.getValueFor(key: "imageName") as? String, !imageName.isEmpty {
            cell.imageView?.image = UIImage(named: imageName)
        }

        return cell
    }
}

extension DXTableViewInfo: UITableViewDelegate {
    //MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.section < sectionInfos.count,
            let cellInfo = sectionInfos[indexPath.section].cell(at: indexPath.row) else {
                return
        }
        if cellInfo.selectionStyle == .none {
            return
        }

        // 将cell的点击事件传递过去
        if let target = cellInfo.target, let sel = cellInfo.selector, target.responds(to: sel) {
            target.perform(sel, with: cellInfo, with: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.section < sectionInfos.count  else { return 0 }
        let section = sectionInfos[indexPath.section]
        return section.cell(at: indexPath.row)?.cellHeight ?? 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section < sectionInfos.count  else { return 0.01 }
        let sectionInfo = sectionInfos[section]
        return sectionInfo.headerHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section < sectionInfos.count  else { return 0.01 }
        let sectionInfo = sectionInfos[section]
        return sectionInfo.footerHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < sectionInfos.count  else { return nil }
        let sectionInfo = sectionInfos[section]
        return sectionInfo.getValueFor(key: "header") as? UIView
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section < sectionInfos.count  else { return nil }
        let sectionInfo = sectionInfos[section]
        return sectionInfo.getValueFor(key: "footer") as? UIView
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section < sectionInfos.count  else { return nil }
        let sectionInfo = sectionInfos[section]
        return sectionInfo.getValueFor(key: "footerTitle") as? String
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < sectionInfos.count  else { return nil }
        let sectionInfo = sectionInfos[section]
        return sectionInfo.getValueFor(key: "headerTitle") as? String
    }
}
