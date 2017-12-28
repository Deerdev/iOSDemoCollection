//
//  IPhoneXBottomBtn.swift
//  zhilian
//
//  Created by daoquan on 2017/12/16.
//  Copyright © 2017年 feixun. All rights reserved.
//

import UIKit

class IPhoneXBottomBtn: UIView {

    private var btn: UIButton!
    private var height: CGFloat = 0.0
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init?(btnHeight: CGFloat, backgroundColor: UIColor = .white) {
        self.init(frame: CGRect.zero)
        if isIphoneX {
            height = PublicStaticTool.iPhoneXIndicatorHeight + btnHeight
        } else {
            height = btnHeight
        }
        self.backgroundColor = backgroundColor
        self.isUserInteractionEnabled = true
        btn = UIButton(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: btnHeight))
        btn.backgroundColor = .clear
        self.addSubview(btn)
    }
    
    func initBtn(_ text: String, _ textColor: UIColor, font: UIFont = UIFont.systemFont(ofSize: 15), isHidden: Bool = false, isEnable: Bool = true) {
        btn.setTitle(text, for: .normal)
        btn.setTitleColor(textColor, for: .normal)
        btn.titleLabel?.font = font
        btn.isHidden = isHidden
        btn.isEnabled = isEnable
    }
    
    func setBtnText(_ text: String) {
        btn.setTitle(text, for: .normal)
    }
    
    func setBtnEnable(_ isEnable: Bool) {
        btn.isEnabled = isEnable
    }
    
    func setBtnHidden(_ isHidden: Bool) {
        btn.isHidden = isHidden
    }
    
    func addBtnTarget(_ target: Any?, action: Selector, for controlEvents: UIControlEvents) {
        btn.addTarget(target, action: action, for: controlEvents)
    }
    
    func makeConstraints() {
        if self.superview == nil {
            return
        }
        
        self.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(0)
            make.height.equalTo(height)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



