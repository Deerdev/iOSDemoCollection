//
//  ViewController.swift
//  BackgroundDownload
//
//  Created by deer on 2018/4/10.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // 34.6M
    let str1 = "http://dl1sw.baidu.com/soft/38/10041/xcn-dvd-creator_6.1.4.0124.exe"
    // 222.5M
    let str2 = "http://183.91.33.52/dlsw.baidu.com/sw-search-sp/soft/43/30736/AshampooMovieStudioPro.1406623896.exe"
    // 4.1M
    let str3 = "http://dlsw.baidu.com/sw-search-sp/soft/b0/17783/bdreader_setup.exe"
    // 11.5
    let str4 = "http://dlsw.baidu.com/sw-search-sp/soft/5f/15630/bsvideosplitter.exe"
    // 31M
    let str5 = "http://211.95.17.50/shunicom1/speedtest/random4000x4000.jpg"

    @IBOutlet weak var progressLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    @IBAction func startDownload(_ sender: UIButton) {
        print("start downloading...")
        NetWorkToolForOneTask.shared.startBackDownload(URLStr: str5)
        NetWorkToolForOneTask.shared.progressBlock = { [weak self] (str) in
            DispatchQueue.main.async {
                self?.progressLabel.text = str
            }
        }
    }

    @IBAction func pauseDownload(_ sender: UIButton) {
        print("pause downloading...")
//        NetWorkToolForOneTask.shared.pauseDownloadTask1()
        NetWorkToolForOneTask.shared.pauseDownloadTask2()
    }

    @IBAction func continueDownload(_ sender: UIButton) {
        print("continue downloading...")
//        NetWorkToolForOneTask.shared.continueTask1()
        NetWorkToolForOneTask.shared.continueTask2()
    }

    @IBAction func startMultiDownload(_ sender: UIButton) {
        print("start multi downloading...")
        multiBackgroundDownload()
    }

    func multiBackgroundDownload() {
        for _ in 0..<4 {
            NetWorkToolForMultiTask.shared.startBackDownload(URLStr: str2)
        }
        
    }
}

