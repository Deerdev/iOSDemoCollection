//
//  SettingViewController.swift
//  YYDeviceScanning
//
//  Created by daoquan on 2018/2/26.
//  Copyright © 2018年 deerdev. All rights reserved.
//

import UIKit
import SVProgressHUD

class SettingViewController: UIViewController {
    @IBOutlet weak var inputApiKey: UITextField!
    @IBOutlet weak var currentBundleId: UILabel!
    @IBOutlet weak var currentSecretKey: UILabel!
    @IBOutlet weak var currentApiKey: UILabel!
    @IBOutlet weak var inputSecetKey: UITextField!
    @IBOutlet weak var saveBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavView()
        currentApiKey.text = k_baiduApiKey
        currentSecretKey.text = k_baiduSecetKey
        currentBundleId.text = Bundle.main.bundleIdentifier
        inputSecetKey.delegate = self
        inputApiKey.delegate = self
    }

    /// 设置导航栏按钮
    func setupNavView() {
        title = "设置百度Key"
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
    }

    /// 返回到上一个视图
    @objc func backToPop() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveBtnClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let apiKey = inputApiKey.text, let secretKey = inputSecetKey.text else {
            SVProgressHUD.showError(withStatus: "请填写key")
            return
        }

        if apiKey.isEmpty || secretKey.isEmpty {
            SVProgressHUD.showError(withStatus: "请填写key")
            return
        }

        UserDefaults.standard.setValue(apiKey, forKey: k_userBaiduApiKey)
        UserDefaults.standard.setValue(secretKey, forKey: k_userBaiduSecetKey)
        k_baiduApiKey = apiKey
        k_baiduSecetKey = secretKey
        SVProgressHUD.showSuccess(withStatus: "保存成功，请继续扫描")
    }

}

extension SettingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 关闭键盘
        view.endEditing(true)
        return true
    }
}
