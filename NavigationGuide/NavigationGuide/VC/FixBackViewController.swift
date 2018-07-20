//
//  FixBackViewController.swift
//  NavigationGuide
//
//  Created by deer on 2018/7/19.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class FixBackViewController: DXBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        clearLeftItem()
        addFixBackBtn()
    }

    func addFixBackBtn() {
        let backbtn = UIButton()
        backbtn.addTarget(self, action: #selector(gotBack), for: .touchUpInside)
        backbtn.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        backbtn.backgroundColor = UIColor.clear

        // 返回箭头的位置
        let imageNormal = UIImage.init(named: "backIcon")
        let imageHighlight = UIImage(named: "backIcon")
        backbtn.setImage(imageNormal, for: .normal)
        backbtn.setImage(imageHighlight, for: .highlighted)
        backbtn.contentHorizontalAlignment = .left
        let btn = UIBarButtonItem(customView: backbtn)

        let fixSpace = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixSpace.width = -15
        self.navigationItem.leftBarButtonItems = [fixSpace, btn]
    }


    @objc func gotBack() {
        navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
