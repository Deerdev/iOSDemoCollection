//
//  ViewController.swift
//  DXTableViewWidget
//
//  Created by deer on 2018/7/20.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var tableInfo: DXTableViewInfo!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        createTableView()
        loadCellInfo()
        tableInfo.getTableView().reloadData()
    }

    func createTableView() {
        let barHeight = UIApplication.shared.statusBarFrame.height + 44
        let frame = CGRect(x: 0, y: barHeight, width: view.bounds.width, height: view.bounds.height - barHeight)
        tableInfo = DXTableViewInfo(frame: frame, style: .grouped)
        view.addSubview(tableInfo.getTableView())
    }

    func loadCellInfo() {
        let cell00 = DXTableViewCellInfo.normalCellFor(title: "无点击事件", rightValue: "点击无效")
        let cell01 = DXTableViewCellInfo.normalCellFor(title: "有图片", rightValue: "点击无效", imageName: "test")
        let cell02 = DXTableViewCellInfo.normalCellFor(selector: #selector(cellClick(params0:params1:)), target: self, title: "可点击", rightValue: "可点击", accessoryType: .disclosureIndicator)
        let cell03 = DXTableViewCellInfo.normalCellFor(selector: #selector(cellClick(params0:params1:)), target: self, title: "可点击", rightValue: "可点击", accessoryType: .disclosureIndicator, imageName: "test")
        let cell04 = DXTableViewCellInfo.centerCellFor(selector: #selector(cellClick(params0:)), target: self, title: "居中可点击")

        let cell10 = DXTableViewCellInfo.switchCellFor(title: "无事件", isOn: true)
        let cell11 = DXTableViewCellInfo.switchCellFor(selector: #selector(cellSwitch(params0:params1:)), target: self, title: "有事件", isOn: true)

        let section0 = DXTableViewSectionInfo.sectionInfoDefault()
        section0.add(cell00)
        section0.add(cell01)
        section0.add(cell02)
        section0.add(cell03)
        section0.add(cell04)

        let section1 = DXTableViewSectionInfo.sectionInfoHeader(with: "switcher")
        section1.add(cell10)
        section1.add(cell11)

        let headView = UIView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 88))
        headView.backgroundColor = .blue
        let section2 = DXTableViewSectionInfo.sectionInfoHeader(with: headView)
        section2.add(cell00)

        let section3 = DXTableViewSectionInfo.sectionInfoWith(headerTitle: "header", headerView: nil, footerTitle: "footer", footerView: nil)
        section3.add(cell00)

        // headview不能复用
        let headView1 = UIView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 88))
        headView1.backgroundColor = .blue
        let footView = UIView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 88))
        footView.backgroundColor = .red
        let section4 = DXTableViewSectionInfo.sectionInfoWith(headerTitle: nil, headerView: headView1, footerTitle: nil, footerView: footView)
        section4.add(cell00)


        // 自定义cell
        let dict = ["headImage": "head", "name": "Deerdev"]
        let cell50 = DXTableViewCellInfo.cellFor(selector: #selector(cellClick(params0:params1:)), target: self, extraSel: #selector(customCellContent(params0:params1:)), extraTarget: self, height: 100, dict: dict, accessoryType: .disclosureIndicator, selectionStyle: .default)
        let section5 = DXTableViewSectionInfo.sectionInfoHeader(with: "自定义cell")
        section5.add(cell50)

        tableInfo.addSection(section0)
        tableInfo.addSection(section1)
        tableInfo.addSection(section2)
        tableInfo.addSection(section3)
        tableInfo.addSection(section4)
        tableInfo.addSection(section5)
    }

}
extension ViewController {
    /// 自定义cell的内容填充
    @objc func customCellContent(params0: UITableViewCell, params1: DXTableViewCellInfo) {
        let imageView = UIImageView.init(frame: CGRect(x: 10, y: 10, width: 80, height: 80))
        imageView.image = UIImage(named: params1.getValueFor(key: "headImage") as? String ?? "")

        let label = UILabel(frame: CGRect(x: 100, y: 0, width: 100, height: 20))
        label.text = params1.getValueFor(key: "name") as? String
        label.sizeToFit()

        params0.contentView.addSubview(imageView)
        params0.contentView.addSubview(label)
        label.center.y = imageView.center.y
    }
}

extension ViewController {
    /// 接收两个参数的点击事件
    @objc func cellClick(params0: DXTableViewCellInfo, params1: IndexPath) {
        debugPrint("click on \(params1)")
    }

    /// 只接收一个参数的点击事件
    @objc func cellClick(params0: DXTableViewCellInfo) {
        debugPrint("click on \(params0)")
    }

    /// switch的valueChange事件
    @objc func cellSwitch(params0: DXTableViewCellInfo, params1: IndexPath) {
        if let isOn = params0.getValueFor(key: "on") as? Bool {
            let title = "有事件" + (isOn ? "(打开)" : "(关闭)")
            params0.add(value: title, for: "title")
            DispatchQueue.main.async {
                self.tableInfo.getTableView().reloadRows(at: [params1], with: .fade)
            }
        }
    }
}

