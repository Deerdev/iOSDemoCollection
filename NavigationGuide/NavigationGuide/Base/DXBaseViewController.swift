//
//  DXBaseViewController.swift
//  NavigationGuide
//
//  Created by deer on 2018/7/17.
//  Copyright © 2018年 deer. All rights reserved.
//
import UIKit

class DXBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
//        self.adjustFrameForIOS7()  
        if let count = navigationController?.viewControllers.count, count > 1 {
            createBackButton()
        }
        view.backgroundColor = .white
        // 去除毛玻璃效果
        navigationController?.navigationBar.isTranslucent = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 设置边缘手势代码
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    func clearLeftItem() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.leftBarButtonItems = nil

        // 隐藏返回/左边按钮(系统自己的返回按钮)
        self.navigationItem.hidesBackButton = true
    }

    func clearRightItem() {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = nil
    }
    /// 创建返回按钮
    @discardableResult
    func createBackButton() -> UIButton {
        let backbtn = UIButton()
        backbtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backbtn.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        backbtn.backgroundColor = UIColor.clear

        // 返回箭头的位置
        let imageNormal = UIImage.init(named: "backIcon")
        let imageHighlight = UIImage(named: "backIcon")
        backbtn.setImage(imageNormal, for: .normal)
        backbtn.setImage(imageHighlight, for: .highlighted)
        backbtn.contentHorizontalAlignment = .left
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbtn)
        return backbtn
    }

    /// 创建取消按钮
    @discardableResult
    func createCancelButton(title: String, any: Any? = nil, action: Selector? = nil) -> UIButton {
        let cancelbtn = UIButton()
        cancelbtn.addTarget(any ?? self, action: action ?? #selector(backAction), for: .touchUpInside)
        cancelbtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        cancelbtn.setTitle(title, for: .normal)
        cancelbtn.setTitleColor(.black, for: .normal)
        cancelbtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelbtn.contentHorizontalAlignment = .left
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelbtn)
        return cancelbtn
    }
    
    /// 创建保存按钮
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - any: 对象
    ///   - action: 事件
    /// - Returns: 保存按钮
    @discardableResult
    func createRightTitleButton(_ title: String, any: Any, action: Selector) -> UIButton {
        let rightBtn = UIButton()
        rightBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        rightBtn.setTitle(title, for: .normal)
        rightBtn.addTarget(any, action: action, for: .touchUpInside)
        rightBtn.setTitleColor(.black, for: .normal)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        rightBtn.contentHorizontalAlignment = .right
        rightBtn.sizeToFit()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        return rightBtn
    }

    @discardableResult
    func createRightImageButton(_ image: UIImage, any: Any, action: Selector) -> UIButton {
        let rightBtn = UIButton()
        rightBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        rightBtn.addTarget(any, action: action, for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        // 返回箭头的位置
        let imageNormal = image
        rightBtn.setImage(imageNormal, for: .normal)
        rightBtn.contentHorizontalAlignment = .right
        return rightBtn
    }
    
    
    /// 返回事件
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    /// 兼容IOS7 以后的界面适配
    func adjustFrameForIOS7 () {
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.extendedLayoutIncludesOpaqueBars = false
        self.modalPresentationCapturesStatusBarAppearance = false
    }
}

extension DXBaseViewController: UIGestureRecognizerDelegate {
    // 是否处理这次开始点击的手势
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let navigationController = self.navigationController {
            if gestureRecognizer == navigationController.interactivePopGestureRecognizer {
                if navigationController.viewControllers.count < 2
                    || navigationController.visibleViewController == navigationController.viewControllers[0] {
                    // 根视图控制器不处理边缘手势，其他控制器处理
                    return false
                }
            }
        }
        return true
    }
}
