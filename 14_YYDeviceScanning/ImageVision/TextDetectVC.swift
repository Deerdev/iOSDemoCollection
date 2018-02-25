//
//  TextDetectVC.swift
//  YYDeviceScanning
//
//  Created by daoquan on 2018/2/24.
//  Copyright © 2018年 deerdev. All rights reserved.
//

import UIKit
import SVProgressHUD

class TextDetectVC: UIViewController {

    var scanResult: ((_ result: String) -> Void)?

    // 默认的识别成功的回调
    var successHandler: ((Any?) -> Void)!
    // 默认的识别失败的回调
    var failHandler: ((Error?) -> Void)!

    var ocrVc: UIViewController?
    var isPresenting = false


    override func viewWillAppear(_ animated: Bool) {
        if isPresenting {
            self.backToPop()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavView()
//        setupLabel()
        configCallBack()
        AipOcrService.shard().auth(withAK: "BHIM89Wu7ThsfX61OaKAxvOD", andSK: "RMgtaOOvZEtHT8KQiRnNA0ly5irGVoyy")
        // Do any additional setup after loading the view.

        let vc = AipGeneralVC.viewController { (image) in
            let options = ["language_type": "ENG", "detect_direction": "true"]
            SVProgressHUD.show()
            AipOcrService.shard().detectTextBasic(from: image, withOptions: options, successHandler: self.successHandler, failHandler: self.failHandler)
        }

        self.present(vc!, animated: false, completion: nil)
        isPresenting = true
        ocrVc = vc
    }

    /// 设置导航栏按钮
    func setupNavView() {
        title = "扫描MAC地址"
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
        navigationController?.popViewController(animated: true)
    }

    func setupLabel() {
        view.backgroundColor = .white
        let label = UILabel(frame: CGRect.zero)
        view.addSubview(label)
        label.text = "请返回"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .gray
        label.sizeToFit()
        label.center = view.center
    }

    func macScanResult(_ mac: String?) {
        DispatchQueue.main.async {
            self.showResult(text: mac?.uppercased())
        }
    }

    func showResult(text: String?) {
        let alert = UIAlertController.init(title: "确认", message: "请手动确认结果", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = text
        }

        let okAction = UIAlertAction(title: "确认", style: .default) { (action) in
            guard let textField = alert.textFields?.first, let confirmedText = textField.text else {
                return
            }
            self.scanResult?(confirmedText)
            self.ocrVc?.dismiss(animated: false, completion: nil)
        }

        let cancelAction = UIAlertAction(title: "重新扫描", style: .cancel) { (action) in
        }

        alert.addAction(cancelAction)
        alert.addAction(okAction)
        ocrVc?.present(alert, animated: true, completion: nil)
    }

    /// 弹窗
    func showAlert() {
        let alert = UIAlertController.init(title: "提示", message: "未扫描到mac地址", preferredStyle: .alert)

        let cancelAction = UIAlertAction.init(title: "重新扫描", style: .cancel) { (_) in
        }
        alert.addAction(cancelAction)
        ocrVc?.present(alert, animated: true, completion: nil)
    }

    func configCallBack() {

        // 这是默认的识别成功的回调
        successHandler = {(result) -> Void in
            SVProgressHUD.dismiss()
            print("\(result)")
            guard let result = result as? [String: Any], let words = result["words_result"] else {
                self.showAlert()
                return
            }

            var message = [String]()
            var mac: String?
            if let words = words as? [String: Any] {
                for (_, obj) in words {
                    if let objdict = obj as? [String: Any] {
                        if let str = objdict["words"] as? String {
                            message.append(str)
                        }
                    } else {
                        if let str = obj as? String {
                            message.append(str)
                        }
                    }
                }
            } else if let words = words as? [Any] {

                for word in words {
                    if let worddict = word as? [String: Any] {
                        if let str = worddict["words"] as? String {
                            message.append(str)
                        }
                    } else {
                        if let str = word as? String {
                            message.append(str)
                        }
                    }
                }
            }

            for str in message {
                let s1 = str.replacingOccurrences(of: " ", with: "")
                let s2 = s1.lowercased()
                if s2.contains("mac") {
                    if let index1 = s2.index(of: ":") {
                        if let index2 = s2.index(of: "/") {
                            mac = String(s2[s2.index(index1, offsetBy: 1)...s2.index(index2, offsetBy: -2)])
                            self.macScanResult(mac)
                        } else {
                            mac = String(s2[s2.index(index1, offsetBy: 1)..<s2.endIndex])
                            self.macScanResult(mac)
                        }
                        break
                    }
                }
            }
            if mac == nil {
                self.showAlert()
            }
        }
        failHandler = {(_ error: Error?) -> Void in
            SVProgressHUD.dismiss()
            print("\(error)")
            self.showAlert()
        }
    }
}
