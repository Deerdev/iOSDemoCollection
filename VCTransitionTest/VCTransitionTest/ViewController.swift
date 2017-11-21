//
//  ViewController.swift
//  VCTransitionTest
//
//  Created by daoquan on 2017/11/20.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let delegate = VCNavigationControllerDelegate()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "渐变过渡"
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.delegate = delegate
    }
    
    @IBAction func btnClicked(_ sender: UIButton) {
        let vc = TransitionViewController()
        self.navigationController?.delegate = delegate
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clearDelegateClicked(_ sender: UIButton) {
        self.navigationController?.delegate = nil
    }
    
    @IBAction func addDelegateClicked(_ sender: UIButton) {
        self.navigationController?.delegate = delegate
    }
}

