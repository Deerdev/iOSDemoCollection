//
//  TransparenceViewController.swift
//  NavigationGuide
//
//  Created by deer on 2018/7/17.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class TransparenceViewController: DXBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .green

//        self.edgesForExtendedLayout = UIRectEdge.all
//        transparenceBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        transparenceBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeBarTransparency()
    }

    func transparenceBar() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.setNavigationBarTransparency(alpha: 0)
    }

    func removeBarTransparency() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setNavigationBarTransparency(alpha: 1)
    }
}
