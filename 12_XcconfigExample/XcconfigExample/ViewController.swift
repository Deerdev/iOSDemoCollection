//
//  ViewController.swift
//  XcconfigExample
//
//  Created by daoquan on 2018/1/25.
//  Copyright © 2018年 deerdev. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    var environment = "debug"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        #if DEBUG
            print("debug")
            let env = "debug"
        #elseif PRERELEASE
            print("prerelease")
            let env = "prerelease"
        #else
            print("release")
            let env = "release"
        #endif

        #if DEV
            print("DEVELOPMENT")
        #elseif PRE
            print("PRE")
        #endif

        environment = env
        addLabelView()

        if let url = infoForKey("Backend Url") {
            print(url)
        }
    }

    func addLabelView() {
        let label = UILabel()
        label.text = environment
        label.sizeToFit()
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }

    func infoForKey(_ key: String) -> String? {
        return (Bundle.main.infoDictionary?[key] as? String)?
            .replacingOccurrences(of: "\\", with: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

