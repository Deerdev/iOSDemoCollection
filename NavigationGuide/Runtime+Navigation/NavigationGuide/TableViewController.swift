//
//  TableViewController.swift
//  NavigationGuide
//
//  Created by deer on 2018/7/17.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    lazy var dataSource = ["自定义返回", "透明导航栏", "隐藏导航栏", "渐变导航栏", "导航栏阴影"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.row < dataSource.count {
            cell.textLabel?.text = dataSource[indexPath.row]
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row >= dataSource.count {
            return
        }
        let title = dataSource[indexPath.row]
        switch title {
        case "自定义返回": baseVC()
        case "透明导航栏": transparenceVC()
        case "隐藏导航栏": hideBarVC()
        case "导航栏阴影": shadowBarVC()
        case "渐变导航栏": GradientBarVC()
        default: break
        }
    }
}

extension TableViewController {
    func baseVC() {
        let vc = TestBaseViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func transparenceVC() {
        let vc = TransparenceViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func hideBarVC() {
        let vc = HideBarViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func shadowBarVC() {
        let vc = ShadowBarViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func GradientBarVC() {
        let vc = ColorBarViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
