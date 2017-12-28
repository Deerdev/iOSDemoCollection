//
//  ViewController.swift
//  VCTransitionTest
//
//  Created by daoquan on 2017/11/20.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let delegate = VCNavigationControllerDelegate()
    private var interactiveTransition: UIPercentDrivenInteractiveTransition!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "过渡方式"
        // Do any additional setup after loading the view, typically from a nib.
        // 添加 右滑加载presentVC手势
        let rightEdgePan = UIScreenEdgePanGestureRecognizer.init(target: self, action: #selector(edgePanGesture(edgePan:)))
        rightEdgePan.edges = .right
        view.addGestureRecognizer(rightEdgePan)
    }
    
    @objc func edgePanGesture(edgePan: UIScreenEdgePanGestureRecognizer) {
        // 加abs 右滑 是负数（当view不同时，可能需要替换view为keyWindow）
        let panProgress = abs(edgePan.translation(in: view).x) / view.frame.width
        
        switch edgePan.state {
        case .began:
            interactiveTransition = UIPercentDrivenInteractiveTransition()
            if edgePan.edges == .right {
                // 加载present vc
                presentToVC()
            } else if edgePan.edges == .left {
                // 开始dismiss vc
                self.dismiss(animated: true, completion: nil)
            }
        case .changed:
            // 更新过渡进度
            interactiveTransition?.update(panProgress)
        case .ended, .cancelled:
            if panProgress > 0.5 {
                // 退出
                interactiveTransition?.finish()
            } else {
                // 恢复
                interactiveTransition?.cancel()
            }
            interactiveTransition = nil
        default: break
        }
    }
    
    @IBAction func PushToViewController(_ sender: UIButton) {
        let vc = PushTransitionViewController()
        self.navigationController?.delegate = delegate
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func PresentToViewCotroller(_ sender: UIButton) {
        presentToVC()
    }
    
    @IBAction func SegueToViewController(_ sender: UIButton) {
    }
    
    func presentToVC() {
        // 从storyboard加载
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "PresentTransitionViewController") as? PresentTransitionViewController {
            // 过场代理
            vc.transitioningDelegate = self
            // 添加手势
            let leftEdgePan = UIScreenEdgePanGestureRecognizer.init(target: self, action: #selector(edgePanGesture(edgePan:)))
            leftEdgePan.edges = .left
            vc.view.addGestureRecognizer(leftEdgePan)
            self.present(vc, animated: true, completion: nil)
        }
    }
}

// MARK: - presen transition delegate
extension ViewController: UIViewControllerTransitioningDelegate {
    /// present动画
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTrasition()
    }
    
    /// dismiss动画
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DissmisTransition()
    }
    
    /// 交互式dimiss动画
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
    
    /// 交互式present动画
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
}
