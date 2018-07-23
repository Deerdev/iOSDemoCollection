//
//  RuntimeTransparenceViewController.swift
//  NavigationGuide
//
//  Created by deer on 2018/7/18.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class RuntimeTransparenceViewController: UIViewController {

    var isTransparency = true
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        self.navBarAlpha = isTransparency ? 0 : 1
        self.navBarTintColor = .red
        self.title = isTransparency ? "透明" : "不透明"
        // Do any additional setup after loading the view.

        let addBtnItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(pushVC))
//        navigationController?.navigationItem.rightBarButtonItem = addBtnItem
        self.navigationItem.rightBarButtonItem = addBtnItem
    }

    @objc func pushVC() {
        let vc = RuntimeTransparenceViewController()
        vc.isTransparency = !isTransparency
        navigationController?.pushViewController(vc, animated: true)
    }
}
