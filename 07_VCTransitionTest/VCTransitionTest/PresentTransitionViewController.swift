//
//  PresentTransitionViewController.swift
//  VCTransitionTest
//
//  Created by daoquan on 2017/11/21.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class PresentTransitionViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        // 添加手势
//        let leftEdgePan = UIScreenEdgePanGestureRecognizer.init(target: self, action: #selector(leftEdgePanGesture(leftEdgePan:)))
//        leftEdgePan.edges = .left
//        view.addGestureRecognizer(leftEdgePan)
//        navigationController?.delegate = self
        
    }
    
    @IBAction func dismissBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
