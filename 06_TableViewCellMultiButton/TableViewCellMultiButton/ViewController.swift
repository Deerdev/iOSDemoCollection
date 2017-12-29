//
//  ViewController.swift
//  TableViewCellMultiButton
//
//  Created by daoquan on 2017/9/3.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var cellDataList: Array<String> =  []
    lazy var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initCellData()
        initTableView()
    }

    func initCellData() {
        for i in 0..<30 {
            cellDataList.append("cell item \(i)")
        }
    }
    
    func initTableView() {
        tableView.frame = CGRect.init(x: 0, y: 20, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 20)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
    }
}

extension ViewController: UITableViewDelegate {
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension ViewController: UITableViewDataSource {
    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell != nil {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "Cell")
        }
        configureCell(cell: cell!, forRowAt: indexPath)
        return cell!
    }
    
    func configureCell(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = cellDataList[indexPath.row]
        // 右侧的箭头
        cell.accessoryType = .disclosureIndicator
        // 取消选中效果
//        cell.selectionStyle = .none
        
        // 添加背景，观察层级
        cell.backgroundColor = .purple
        cell.contentView.backgroundColor = .blue
        if cell.isKind(of: UIScrollView.self) {
            print("xxx")
        }
        for view in cell.subviews {
            if view.isKind(of: UIScrollView.self) {
                print("xxx")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cellDataList.remove(at: indexPath.row)
            // 无动画
            //            tableView.reloadData()
            tableView.deleteRows(at: [indexPath], with: .right)
        } else {
            print("No operation for \(editingStyle)")
        }
    }
}
