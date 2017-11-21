//
//  FadeInTransition.swift
//  VCTransitionTest
//
//  Created by daoquan on 2017/11/20.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class FadeInTransition: NSObject, UIViewControllerAnimatedTransitioning {
    /// 记录是 push/pop
    var operation: UINavigationControllerOperation?

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
        if operation == .push {
            containView.addSubview(toView)
            toView.alpha = 0
            let originFrame = toView.frame
            toView.frame = CGRect.init(x: originFrame.origin.x, y: originFrame.origin.y + 667, width: originFrame.width, height: originFrame.height)
            // 向上渐变加载
            UIView.animate(withDuration: durationTime, animations: {
                toView.alpha = 1
                toView.frame = originFrame
            }, completion: { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
        } else if operation == .pop {
            containView.insertSubview(toView, belowSubview: fromView)
            let originFrame = fromView.frame
            // 向下渐变退出
            UIView.animate(withDuration: durationTime, animations: {
                fromView.alpha = 0
                fromView.frame = CGRect.init(x: originFrame.origin.x, y: originFrame.origin.y + 667, width: originFrame.width, height: originFrame.height)
            }, completion: { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
    
    /// 动画的过渡时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
}
