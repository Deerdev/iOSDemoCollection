//
//  ViewController.swift
//  SpeedUnitTest
//
//  Created by daoquan on 2017/9/1.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var value1: Float = 0.0
    var value2: Float = 0.8
    var customeView: CustomView?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let button = UIButton.init(frame: CGRect(x: 135, y: 30, width: 100, height: 200))
        button.setTitle("Start", for: UIControlState.normal)
        button.setTitleColor(UIColor.red, for: UIControlState.normal)
        button.addTarget(self, action: #selector(tapStartBtn), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button)
        
        customeView = CustomView.init(frame: CGRect(x: 0, y: 150, width: UIScreen.main.bounds.size.width, height: 500))
        self.view.addSubview(customeView!);
        
    }
    
    func tapStartBtn(bt: UIButton) {
        customeView?.addUntitled1Animation(completionBlock: nil, value1: value1, value2: value2)
        value1 = value2
        value2 = value2 - 0.2
        if value2 <= 0.0 {
            value2 = 0.8
            value1 = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

