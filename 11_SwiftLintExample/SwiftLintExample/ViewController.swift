//
//  ViewController.swift
//  SwiftLintExample
//
//  Created by daoquan on 2018/1/24.
//  Copyright © 2018年 deerdev. All rights reserved.
//  swiftlint:disable identifier_name

import UIKit

class ViewController: UIViewController {

    // swiftlint:disable colon
    var name:String = "deerdev"
    // swiftlint:enable colon

    var MyAge: Int = 18

    @objc  var nal = "sss"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIView.animate(withDuration: 1) {
            print("\(self.name) is \(self.MyAge) years old")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
