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
        let cell04 = DXTableViewCellInfo.centerCellFor(selector: #selector(cellClick(params0:params1:)), target: self, title: "居中可点击")

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


        tableInfo.addSection(section0)
        tableInfo.addSection(section1)
        tableInfo.addSection(section2)
        tableInfo.addSection(section3)
        tableInfo.addSection(section4)
    }

}

extension ViewController {
    @objc func cellClick(params0: DXTableViewCellInfo, params1: IndexPath) {
        debugPrint("click on \(params1)")
    }

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

