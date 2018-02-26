//
//  AddDeviceViewController.swift
//  YYDeviceScanning
//
//  Created by daoquan on 2018/2/24.
//  Copyright © 2018年 deerdev. All rights reserved.
//

import UIKit
import SVProgressHUD

struct cellModel {
    var cell: CellType
    var placeHold: String
    var isNeedScan: Bool
    var text: String?
}

enum CellType {
    case device
    case person
    case sn
    case mac
}

class AddDeviceViewController: UITableViewController {

    private var isEditingInfo = false
    var info: DeviceInfo? {
        didSet {
            if info != nil {
                isEditingInfo = true
            } else {
                isEditingInfo = false
            }
        }
    }


    private var dataList: [cellModel]!
    private var idCell: AddDeviceTableViewCell? {
        let snIndex = IndexPath(row: 0, section: 0)
        let cell = self.tableView.cellForRow(at: snIndex)
        return (cell as? AddDeviceTableViewCell) ?? nil
    }
    private var ownerCell: AddDeviceTableViewCell? {
        let snIndex = IndexPath(row: 1, section: 0)
        let cell = self.tableView.cellForRow(at: snIndex)
        return (cell as? AddDeviceTableViewCell) ?? nil
    }
    private var snCell: AddDeviceTableViewCell? {
        let snIndex = IndexPath(row: 0, section: 1)
        let cell = self.tableView.cellForRow(at: snIndex)
        return (cell as? AddDeviceTableViewCell) ?? nil
    }

    private var macCell: AddDeviceTableViewCell? {
        let snIndex = IndexPath(row: 1, section: 1)
        let cell = self.tableView.cellForRow(at: snIndex)
        return (cell as? AddDeviceTableViewCell) ?? nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initModels()
        setupNavView()


    }

    func initModels() {

        let cell0 = cellModel(cell: .device, placeHold: "K2", isNeedScan: false, text: info?.productId)
        let cell1 = cellModel(cell: .person, placeHold: "设备在谁名下", isNeedScan: false, text: info?.owner)
        let cell2 = cellModel(cell: .sn, placeHold: "序列号", isNeedScan: true, text: info?.sn)
        let cell3 = cellModel(cell: .mac, placeHold: "mac地址", isNeedScan: true, text: info?.mac)
        dataList = [cell0, cell1, cell2, cell3]
    }

    /// 设置导航栏按钮
    func setupNavView() {
        if !isEditingInfo {
            title = "添加设备"
        } else {
            title = "编辑设备"
        }
        //1.返回按钮
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        backBtn.contentHorizontalAlignment = .left
        backBtn.setBackgroundImage(UIImage(named: "nav_back_orange"), for: .normal)
        //backBtn.contentMode=UIViewContentModeScaleAspectFit;
        backBtn.addTarget(self, action: #selector(self.backToPop), for: .touchUpInside)
        let leftItem = UIBarButtonItem(customView: backBtn)
        //leftItem.imageInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
        self.navigationItem.leftBarButtonItem = leftItem
        //2.完成按钮
        let doneBtn = UIButton(type: .custom)
        doneBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 35)
        doneBtn.setTitle("保存", for: .normal)
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        doneBtn.setTitleColor(UIColor.orange, for: .normal)
        doneBtn.contentHorizontalAlignment = .right
        //albumBtn.contentMode=UIViewContentModeScaleAspectFit;
        doneBtn.addTarget(self, action: #selector(self.done), for: .touchUpInside)
        let rightItem = UIBarButtonItem(customView: doneBtn)
        self.navigationItem.rightBarButtonItem = rightItem
    }

    /// 返回到上一个视图
    @objc func backToPop() {
        if navigationController?.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc func done() {
        if judgeEmpty() {
            NotificationCenter.default.post(name: NSNotification.Name.init(k_refreshDBData), object: nil)
            backToPop()
        } else {
            print("save error")
            SVProgressHUD.showError(withStatus: "请填写好所有信息！")
        }
    }

    func judgeEmpty() -> Bool {
        guard let cell0Text = idCell?.inputText.text,
            let cell1Text = ownerCell?.inputText.text,
            let cell2Text = snCell?.inputText.text,
            let cell3Text = macCell?.inputText.text else {
            return false
        }

        if cell0Text.count < 1
            || cell1Text.count < 1
            || cell2Text.count < 1
            || cell3Text.count < 1 {
            return false
        }

        let info = DeviceInfo.init(cell0Text.uppercased(), cell1Text, cell2Text.uppercased(), cell3Text.uppercased(), nil)

        if isEditingInfo {
            info.dbId = self.info?.dbId
            if !DBOperation.shared.updateInfo(info) {
                return false
            }
        } else {
            if !DBOperation.shared.insertInfoToDB(info) {
                return false
            }
        }
        return true
    }
}

extension AddDeviceViewController: AddDeviceTableViewCellDelegate {
    func scanSnNumber() {
        let scanVC = QRCodeScanVC(with: "S/N扫描", isShowAlbum: true, isShowFlash: true)
        scanVC.scanResult = { (result) in
            guard let cell = self.snCell else { return }
            cell.setSnNumber(result)
        }
        navigationController?.pushViewController(scanVC, animated: true)
    }

    func scanMacAddress() {
        let scanVC = QRCodeScanVC(with: "MAC地址扫描", isShowAlbum: true, isShowFlash: true)
        scanVC.scanResult = { (result) in
            guard let cell = self.macCell else { return }
            cell.setMacAddress(result)
        }
        navigationController?.pushViewController(scanVC, animated: true)
    }

    func macTextDetect() {
        let vc = TextDetectVC()
        vc.scanResult = { (result) in
            guard let cell = self.macCell else { return }
            cell.setMacAddress(result)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AddDeviceViewController {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
                return nil
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddDeviceTableViewCell", for: indexPath)
        configureCell(cell: cell, forRowAt: indexPath)
        return cell
    }

    func configureCell(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? AddDeviceTableViewCell else { return }
        if indexPath.row < dataList.count {
            if indexPath.section > 0 {
                cell.setModel(dataList[indexPath.row + 2])
            } else {
                cell.setModel(dataList[indexPath.row])
            }
            cell.delegate = self
        }
    }
}
