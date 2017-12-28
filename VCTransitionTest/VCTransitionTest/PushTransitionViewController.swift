//
//  FadeInViewController.swift
//  VCTransitionTest
//
//  Created by daoquan on 2017/11/20.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class PushTransitionViewController: UIViewController, UINavigationControllerDelegate {

    private var interactiveTransition: UIPercentDrivenInteractiveTransition?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .red
        // 添加手势
        let leftEdgePan = UIScreenEdgePanGestureRecognizer.init(target: self, action: #selector(leftEdgePanGesture(leftEdgePan:)))
        leftEdgePan.edges = .left
        view.addGestureRecognizer(leftEdgePan)
        navigationController?.delegate = self
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            navigationController?.delegate = nil
        }
        super.didMove(toParentViewController: parent)
    }
    
    @objc func leftEdgePanGesture(leftEdgePan: UIScreenEdgePanGestureRecognizer) {
        let panProgress = leftEdgePan.translation(in: view).x / view.frame.width
        
        switch leftEdgePan.state {
        case .began:
            print("start:\(panProgress)")
            interactiveTransition = UIPercentDrivenInteractiveTransition()
            // 开始退出界面
            navigationController?.popViewController(animated: true)
        case .changed:
            // 更新过渡进度
            print("change:\(panProgress)")
            interactiveTransition?.update(panProgress)
        case .ended, .cancelled:
            if panProgress > 0.5 {
                // 退出
                print("exit:\(panProgress)")
                interactiveTransition?.finish()
            } else {
                // 恢复
                print("restore:\(panProgress)")
                interactiveTransition?.cancel()
            }
            interactiveTransition = nil
        default: break
        }
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if operation == .pop {
            let transition = FadeInTransition()
            transition.operation = .pop
            return transition
        } else {
            return nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if animationController.isKind(of: FadeInTransition.self) {
            return interactiveTransition
        } else {
            return nil
        }
    }

}
