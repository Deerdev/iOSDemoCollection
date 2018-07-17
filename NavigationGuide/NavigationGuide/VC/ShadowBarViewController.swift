//
//  ShadowBarViewController.swift
//  NavigationGuide
//
//  Created by deer on 2018/7/17.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class ShadowBarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
