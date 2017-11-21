//
//  ItemTableViewCell.swift
//  TableViewCellMultiButton
//
//  Created by daoquan on 2017/9/4.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var viewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel!

    @IBOutlet weak var myContentView: UIView!
    @IBOutlet weak var Btn2: UIButton!
    @IBOutlet weak var Btn1: UIButton!
    
    var panGesture: UIPanGestureRecognizer!
    var startGesturePoint: CGPoint!
    var viewStartingRightConstraintValue: CGFloat!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addGesture()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// 添加手势
    func addGesture() {
        panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panTheCell(sender:)))
        panGesture.delegate = self
        myContentView.addGestureRecognizer(panGesture)
    }
    
    
    /// 手势变化
    func panTheCell(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            // 开始手势
            startGesturePoint = sender.translation(in: myContentView)
            viewStartingRightConstraintValue = viewRightConstraint.constant
        case .changed:
            // 手势改变，判断是不是在向左滑
            let currentPoint = sender.translation(in: myContentView)
            // 滑动点距离 开始点的 距离
            let deltaX = currentPoint.x - startGesturePoint.x
            // 是不是向左滑动
            var isLeftPan = false
            if currentPoint.x < startGesturePoint.x {
                isLeftPan = true
            }
            
            if viewStartingRightConstraintValue == 0 {
                // 左滑/右滑 -> 关闭 的临界判断
                if isLeftPan {
                    // 从关闭 -> 左滑（更新约束）
                    let constant = min(-deltaX, totalButtonWidth())
                    if constant == totalButtonWidth() {
                        // TODO: 滑动打开button界面
                    } else {
                        // 更新约束
                        viewRightConstraint.constant = constant
                    }
                } else {
                    // 右滑 -> 关闭（更新约束）
                    let constant = max(-deltaX, 0)
                    if constant == 0 {
                        // TODO: 关闭滑动界面
                    } else {
                        // 更新约束
                        viewRightConstraint.constant = constant
                    }
                }
            } else {
                // 正在滑动的过程中（已经是open状态，button都显示出来了，进行新的滑动）
                // 滑动的偏差（初始约束 减去 滑动距离）
                let adjustDistance = viewStartingRightConstraintValue - deltaX
                if isLeftPan {
                    // 左滑 更新约束
                    // 是否滑动到 两个button的宽度
                    let constant = min(adjustDistance, totalButtonWidth())
                    if constant == totalButtonWidth() {
                        // 滑动打开button界面：滑动到button都显示出来了-> 显示button界面
                        // TODO: 显示button
                    } else {
                        // 没有滑动到button都显示出来 -> 更新约束
                        viewRightConstraint.constant = constant
                    }
                } else {
                    // 右滑 更新约束
                    let constant = max(adjustDistance, 0)
                    if constant == 0 {
                        // TODO: 关闭滑动界面
                    } else {
                        // TODO: 更新约束
                        viewRightConstraint.constant = constant
                    }
                }
            }
            viewLeftConstraint.constant = -viewRightConstraint.constant
            
        case .ended:
            // 手势结束（如果滑动超过一个button的宽度 -> 显示全部button）
            
            if viewStartingRightConstraintValue == 0 {
                // 从0开始滑动，正在open
                let openWidth = Btn2.frame.width
                if viewRightConstraint.constant >= openWidth {
                    // TODO: 显示所有button
                } else {
                    // TODO: 关闭滑动 close
                }
            } else {
                // 关闭（open状态 -> 继续想左滑 -> 松手）
                let openWidth = Btn1.frame.width + Btn2.frame.width/2
                if viewRightConstraint.constant >= openWidth {
                    // TODO: 显示所有button(re-open)
                } else {
                    // TODO: 关闭滑动 close
                }
                
            }
        case .cancelled:
            // 手势取消
            if viewStartingRightConstraintValue == 0 {
                // 从0开始滑动，正在open
                // TODO: 关闭滑动 close
            } else {
                // 关闭（open状态 -> 继续想左滑 -> 松手）
                // TODO: 显示所有button(re-open)
            }
        default: break
        }
    }
    
    /// 返回两个可点击按钮的 总宽度
    func totalButtonWidth() -> CGFloat {
        //
        return (self.frame.width - Btn1.frame.minX)
        
    }
    /// 按钮点击
    ///
    /// - Parameter sender: 被点击的按钮
    @IBAction func BtnClick(_ sender: UIButton) {
        if sender == Btn1 {
            print("Btn1 clicked!")
        } else if sender == Btn2 {
            print("Btn2 clicked!")
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
