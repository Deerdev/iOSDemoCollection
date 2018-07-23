//
//  ShadowBarViewController.swift
//  NavigationGuide
//
//  Created by deer on 2018/7/17.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class ShadowBarViewController: DXBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBarShadow()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeBarShadow()
    }

    func addBarShadow() {
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.layer.shadowColor = UIColor.blue.cgColor
        navigationController.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 10)
        navigationController.navigationBar.layer.shadowRadius = 16
        navigationController.navigationBar.layer.shadowOpacity = 0.5
        // 需要设置路径
//        navigationController.navigationBar.layer.shadowPath = UIBezierPath.init(rect: navigationController.navigationBar.bounds).cgPath
    }

    func removeBarShadow() {
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.shadowImage = nil
        navigationController.navigationBar.layer.shadowColor = UIColor.white.cgColor
        navigationController.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        navigationController.navigationBar.layer.shadowRadius = 0
        navigationController.navigationBar.layer.shadowOpacity = 0
    }
}
