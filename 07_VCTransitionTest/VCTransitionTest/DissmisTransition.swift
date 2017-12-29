//
//  DissmisTransition.swift
//  VCTransitionTest
//
//  Created by daoquan on 2017/11/21.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class DissmisTransition: NSObject, UIViewControllerAnimatedTransitioning {

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
        
        containView.insertSubview(toView, belowSubview: fromView)

        // 向下渐变退出
        UIView.animate(withDuration: durationTime, animations: {
            fromView.alpha = 0
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
