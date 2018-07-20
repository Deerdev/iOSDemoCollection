//
//  ViewController.swift
//  DXTableViewWidget
//
//  Created by deer on 2018/7/20.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func initTableView() {
        let tableInfo = DXTableViewInfo(frame: view.bounds, style: .grouped)
    }

}

