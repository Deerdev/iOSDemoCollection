//
//  TestBaseViewController.swift
//  NavigationGuide
//
//  Created by deer on 2018/7/17.
//  Copyright © 2018年 deer. All rights reserved.
// https://www.jianshu.com/p/94910b42396c

import UIKit

class TestBaseViewController: DXBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "测试"
        printSubviws(navigationController?.navigationBar, andLevel: 0)
    }

    func printSubviws(_ view: UIView?, andLevel level: Int) {
        guard let view = view else { return }
        let subviews = view.subviews
        // 如果没有子视图就直接返回
        if subviews.count == 0 {
            return
        }
        for subview in subviews {
            // 根据层级决定前面空格个数，来缩进显示
            var blank = ""
            for _ in 0..<level {
                blank = "  \(blank)"
            }
            // 打印子视图类名
            print("\(blank)\(level): \(subview.self)")
            // 递归获取此视图的子视图
            printSubviws(subview, andLevel: level + 1)
        }
    }

    /**
     UINavigationBar 层级关系

     0: <_UIBarBackground> (背景视图)
         1: <UIImageView> (背景图片)
         1: <UIVisualEffectView> (毛玻璃效果)
             2: <_UIVisualEffectBackdropView>
             2: <_UIVisualEffectSubview>
     0: <_UINavigationBarLargeTitleView> (iOS11 大标题)
        1: <UILabel>
     0: <_UINavigationBarContentView> (包裹 按钮和title的view)
     0: <_UINavigationBarModernPromptView>
        1: <UILabel>

    */

}
