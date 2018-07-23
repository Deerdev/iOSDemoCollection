//
//  ColorBarViewController.swift
//  NavigationGuide
//
//  Created by deer on 2018/7/18.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

extension UIColor {
    class func hex(hex: Int, alpha: CGFloat = 1) -> UIColor {
        var trans = alpha
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        var red = (hex >> 16) & 0xff
        var green = (hex >> 8) & 0xff
        var blue = hex & 0xff

        red = max(min(red, 0), 255)
        green = max(min(green, 0), 255)
        blue = max(min(blue, 0), 255)
        return self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
}

var SCREEN_WIDTH = UIScreen.main.bounds.width
class ColorBarViewController: DXBaseViewController {
    var blurBackView: UIView = {
        let blurBackView = UIView()
        blurBackView.frame = CGRect(x: 0, y: -20, width: SCREEN_WIDTH, height: 64)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64)
        let color1 = UIColor.init(red: 0.0156863, green: 0, blue: 0.0705882, alpha: 1)
        let color2 = UIColor.init(red: 0.0156863, green: 0, blue: 0.0705882, alpha: 0.1)
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1.0)
        blurBackView.layer.addSublayer(gradientLayer)
        blurBackView.isUserInteractionEnabled = false
        blurBackView.alpha = 0.5
        return blurBackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        title = "联系人"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        insertBlurView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeBlurView()
    }

    func insertBlurView() {
        blurBackView.removeFromSuperview()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barStyle = .black
//        navigationController?.navigationBar.insertSubview(blurBackView, at: 0)
        navigationController?.navigationBar.subviews[0].insertSubview(blurBackView, at: 0)
    }

    func removeBlurView() {
        blurBackView.removeFromSuperview()
        navigationController?.navigationBar.barStyle = .default
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
