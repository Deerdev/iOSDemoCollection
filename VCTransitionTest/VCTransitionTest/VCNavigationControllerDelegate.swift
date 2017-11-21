//
//  VCNavigationControllerDelegate.swift
//  VCTransitionTest
//
//  Created by daoquan on 2017/11/20.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class VCNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        // 返回自定义动画
        let transition = FadeInTransition()
        transition.operation = operation
        return transition
    }
}
