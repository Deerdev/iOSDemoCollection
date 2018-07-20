//
//  RuntimeTableViewController.swift
//  NavigationGuide
//
//  Created by deer on 2018/7/18.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class RuntimeTableViewController: UITableViewController {

    lazy var dataSource = ["透明导航栏(runtime)", "滑动渐变"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        view.backgroundColor = .orange
        tableView.backgroundColor = .orange
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
        cell.backgroundColor = .orange
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row >= dataSource.count {
            return
        }
        let title = dataSource[indexPath.row]
        switch title {
        case "透明导航栏(runtime)": transparenceVC()
        case "滑动渐变": scrollTransparenceVC()
        default: break
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


extension RuntimeTableViewController {
    func baseVC() {
        let vc = TestBaseViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func transparenceVC() {
        let vc = RuntimeTransparenceViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func scrollTransparenceVC() {
        let vc = ScrollTransparencyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func shadowBarVC() {
        let vc = ShadowBarViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
