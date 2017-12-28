//
//  PresentTrasition.swift
//  VCTransitionTest
//
//  Created by daoquan on 2017/11/21.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class PresentTrasition: NSObject, UIViewControllerAnimatedTransitioning {

    /// 动画的实现
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // 过场view
        let containView = transitionContext.containerView
        // 获取过场的 源控制器(view) 和 目的控制器(view)
        guard let toView = transitionContext.view(forKey: .to),
            //            let toVC = transitionContext.viewController(forKey: .to),
            //            let fromVC = transitionContext.viewController(forKey: .from),
            let fromView = transitionContext.view(forKey: .from)
            else { return }
        
        // 获取过场时间
        let durationTime = transitionDuration(using: transitionContext)
        // 根据不同的过程 加载动画
        containView.addSubview(toView)
        toView.alpha = 0
        let originTransform = toView.layer.transform
        toView.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi / 2), 0, 1, 0)

        // 向上渐变加载
        UIView.animate(withDuration: durationTime, animations: {
            toView.alpha = 1
            toView.layer.transform = originTransform
        }, completion: { (_) in
            // 结束转场
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    /// 动画的过渡时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
}
