//
//  DXNavigationVC.swift
//  NavigationGuide
//
//  Created by deer on 2018/7/17.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    convenience init?(title: String, imageName: String? = nil, target: Any?, action: Selector) {
        self.init()
        
        let button = UIButton()
        if imageName != nil {
            button.setImage(UIImage(named: imageName!), for: .normal)
        }
        
        button.addTarget(target, action: action, for: .touchUpInside)
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setTitleColor(UIColor.orange, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.sizeToFit()
        
        customView = button
    }
}

class DXNavigationVC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if !childViewControllers.isEmpty {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    func backButton() {
        let back = UIBarButtonItem(title: "", imageName: "navbar_btn_back", target: self, action: #selector(backAction))
        
        self.navigationItem.leftBarButtonItem = back
    }
    
    @objc func backAction() {
        popViewController(animated: true)
    }
    
    
}
