//
//  ViewController.swift
//  YYDeviceScanning
//
//  Created by daoquan on 2018/2/23.
//  Copyright © 2018年 deerdev. All rights reserved.
//

import UIKit
import SVProgressHUD

class MainViewController: UITableViewController {

    private var scanbtn: UIButton!
    private var deviceList = [DeviceInfo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "登记设备"

        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name.init(k_refreshDBData), object: nil)
        setupNavView()
        if DBOperation.shared.creatDB() {
            if let devices = DBOperation.shared.loadInfoFromDB() {
                deviceList = devices
                tableView.reloadData()
            } else {
                SVProgressHUD.showInfo(withStatus: "尚无数据，请添加！")
            }
        } else {
            SVProgressHUD.showInfo(withStatus: "请重启App，创建数据库！")
        }
    }

    @objc func refreshData() {
        if let devices = DBOperation.shared.loadInfoFromDB() {
            deviceList = devices
            tableView.reloadData()
        }
    }

    /// 设置导航栏按钮
    func setupNavView() {

        let albumBtn = UIButton(type: .custom)
        albumBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 35)
        albumBtn.setTitle("添加", for: .normal)
        albumBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        albumBtn.setTitleColor(UIColor.orange, for: .normal)
        albumBtn.contentHorizontalAlignment = .right
        //albumBtn.contentMode=UIViewContentModeScaleAspectFit;
        albumBtn.addTarget(self, action: #selector(self.addDevice), for: .touchUpInside)
        let rightItem = UIBarButtonItem(customView: albumBtn)
        self.navigationItem.rightBarButtonItem = rightItem
    }

    @objc func addDevice() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddDeviceViewController")
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
}

extension MainViewController {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "AddDeviceViewController") as? AddDeviceViewController {
            vc.info = indexPath.row < deviceList.count ? deviceList[indexPath.row] : nil
            navigationController?.pushViewController(vc, animated: true)
        }

    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 25.0))
        let label = UILabel(frame: CGRect.zero)
        view.addSubview(label)
        label.text = "请经常使用iTunes备份数据库"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        label.sizeToFit()
        label.center = view.center
        return view
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if DBOperation.shared.deleteIndo(deviceList[indexPath.row]) {
                deviceList.remove(at: indexPath.row)
                tableView.reloadData()
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath)
        configureCell(cell: cell, forRowAt: indexPath)
        return cell
    }

    func configureCell(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? MainTableViewCell else { return }
        if indexPath.row < deviceList.count {
            cell.setModel(deviceList[indexPath.row], indexPath.row + 1)
//            cell.delegate = self
        }
    }
}

