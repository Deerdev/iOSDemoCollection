//
//  UINavigationController(Transparent).swift
//  NavigationGuide
//
//  Created by deer on 2018/7/18.
//  Copyright © 2018年 deer. All rights reserved.
//
// 参考: https://github.com/EnderTan/ETNavBarTransparent

import UIKit

/// dispatch_once
public extension DispatchQueue {
    private static var _onceTracker = [String]()
    public class func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }
}

extension UINavigationController {
    /// 设置导航栏的透明度
    func setNavigationBarTransparency(alpha: CGFloat) {
        let barBackgroundView = navigationBar.subviews[0]
        let valueForBarBackViewKey = barBackgroundView.value(forKey:)

        // 通过subviews去取子view的风险：隐藏的导航栏二次进入该方法时，subviews只有一个
        if let shadowView = valueForBarBackViewKey("_shadowView") as? UIView {
            shadowView.alpha = alpha
            shadowView.isHidden = alpha == 0
        }

        if navigationBar.isTranslucent {
            if #available(iOS 10.0, *) {
                // 如果没有设置自定义 背景图片
                if let backEffectView = valueForBarBackViewKey("_backgroundEffectView") as? UIView, navigationBar.backgroundImage(for: .default) == nil {
                    backEffectView.alpha = alpha
                    return
                }
            } else {
                if let adaptiveBackdrop = valueForBarBackViewKey("_adaptiveBackdrop") as? UIView , let backdropEffectView = adaptiveBackdrop.value(forKey: "_backdropEffectView") as? UIView {
                    backdropEffectView.alpha = alpha
                    return
                }
            }
        }
        barBackgroundView.alpha = alpha
    }
}

/**
 因为导航栏是全局设置的，一个VC设置了透明，同一堆栈中的VC也会变透明
 所以，最好每个VC都保存自己的透明度(runtime添加)

 同理：可以保存每个VC的 barTintColor
 */
extension UIViewController {
    private struct AssociateKeys {
        static var navBarAlpha = "navBarAlpha"
        static var navBarTintColor = "navBarTintColor"
    }

    /// 导航栏透明度
    var navBarAlpha: CGFloat {
        get {
            guard let alpha = objc_getAssociatedObject(self, &AssociateKeys.navBarAlpha) as? CGFloat else { return 1.0 }
            return alpha
        }
        set {
            let alpha = max(min(newValue, 1), 0)
            objc_setAssociatedObject(self, &AssociateKeys.navBarAlpha, alpha, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            // 修改透明度
            navigationController?.setNavigationBarTransparency(alpha: alpha)
        }
    }

    open var navBarTintColor: UIColor {
        get {
            guard let tintColor = objc_getAssociatedObject(self, &AssociateKeys.navBarTintColor) as? UIColor else {
                // 默认导航栏颜色
                return UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1.0)
            }
            return tintColor
        }
        set {
            objc_setAssociatedObject(self, &AssociateKeys.navBarTintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            navigationController?.navigationBar.tintColor = newValue
        }
    }
}

/// 修复左滑返回时 渐变效果过渡 不友好
extension UINavigationController {

    /// 传递设置status bar颜色
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }

    override open func viewDidLoad() {
//        UINavigationController.methodSwizzle()
        super.viewDidLoad()
    }

    private static let onceToken = UUID().uuidString
    class func methodSwizzle() {
        guard self == UINavigationController.self else { return }

        DispatchQueue.once(token: onceToken) {
            // 交换方法
            let swizzleMethodSelectors = [NSSelectorFromString("_updateInteractiveTransition:"), #selector(popToViewController), #selector(popToRootViewController)]

            for selector in swizzleMethodSelectors {
                let swizzleName = ("dx_" + selector.description).replacingOccurrences(of: "__", with: "_")
                if let originMethod = class_getInstanceMethod(self, selector), let swizzleMethod = class_getInstanceMethod(self, Selector(swizzleName)) {
                    method_exchangeImplementations(originMethod, swizzleMethod)
                }
            }
        }
    }

    /// 左滑返回 动画过渡的进度（0-1）
    @objc func dx_updateInteractiveTransition(_ percentComplete: CGFloat) {
        guard let topViewController = topViewController, let coordinator = topViewController.transitionCoordinator else {
            dx_updateInteractiveTransition(percentComplete)
            return
        }

        let fromViewController = coordinator.viewController(forKey: .from)
        let toViewController = coordinator.viewController(forKey: .to)

        // Bg Alpha
        let fromAlpha = fromViewController?.navBarAlpha ?? 0
        let toAlpha = toViewController?.navBarAlpha ?? 0
        let newAlpha = fromAlpha + (toAlpha - fromAlpha) * percentComplete

        setNavigationBarTransparency(alpha: newAlpha)

        // Tint Color
        let fromColor = fromViewController?.navBarTintColor ?? .blue
        let toColor = toViewController?.navBarTintColor ?? .blue
        let newColor = averageColor(fromColor: fromColor, toColor: toColor, percent: percentComplete)
        navigationBar.tintColor = newColor
        dx_updateInteractiveTransition(percentComplete)
    }

    /// 根据左滑进度 计算过渡过程中的颜色
    private func averageColor(fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor {
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)

        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)

        let nowRed = fromRed + (toRed - fromRed) * percent
        let nowGreen = fromGreen + (toGreen - fromGreen) * percent
        let nowBlue = fromBlue + (toBlue - fromBlue) * percent
        let nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percent

        return UIColor(red: nowRed, green: nowGreen, blue: nowBlue, alpha: nowAlpha)
    }

    // MARK: - 常规的返回操作
    @objc func dx_popToRootViewController(animated: Bool) -> [UIViewController]? {
        setNavigationBarTransparency(alpha: viewControllers.first?.navBarAlpha ?? 0)
        navigationBar.tintColor = viewControllers.first?.navBarTintColor
        return dx_popToRootViewController(animated: animated)
    }

    @objc func dx_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        setNavigationBarTransparency(alpha: viewController.navBarAlpha)
        navigationBar.tintColor = viewController.navBarTintColor
        return dx_popToViewController(viewController, animated: animated)
    }
}

/// 手势滑动中时，可能会取消手势，需要更新当前页面的透明度
extension UINavigationController: UINavigationBarDelegate {

    /// 根据UINavigationItem的代理（是否弹出UINavigationItem）来判断手势 和 返回 按钮的场景
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if let topVC = topViewController, let coordiator = topVC.transitionCoordinator, coordiator.initiallyInteractive {
            // 如果是手势交互
            if #available(iOS 10.0, *) {
                coordiator.notifyWhenInteractionChanges { (context) in
                    self.dealInteractionChanges(context)
                }
            } else {
                coordiator.notifyWhenInteractionEnds { (context) in
                    self.dealInteractionChanges(context)
                }
            }
            return true
        }

        // 如果是按钮返回
        if let itemCount = navigationBar.items?.count {
            let vcCount = viewControllers.count
            let n = vcCount >= itemCount ? 2 : 1
            let popToVC = viewControllers[vcCount - n]
            // 重写此代理 需要手动弹出 vc（这里是弹出到指定vc）
            // https://stackoverflow.com/questions/42581851/uinavigationbardelegate-shouldpop-item-weird-behavior
            popToViewController(popToVC, animated: true)
        }
        return true
    }

    public func navigationBar(_ navigationBar: UINavigationBar, shouldPush item: UINavigationItem) -> Bool {
        setNavigationBarTransparency(alpha: topViewController?.navBarAlpha ?? 0)
        navigationBar.tintColor = topViewController?.navBarTintColor
        return true
    }

    private func dealInteractionChanges(_ context: UIViewControllerTransitionCoordinatorContext) {
        let animations: (UITransitionContextViewControllerKey) -> () = {
            let nowAlpha = context.viewController(forKey: $0)?.navBarAlpha ?? 0
            self.setNavigationBarTransparency(alpha: nowAlpha)

            self.navigationBar.tintColor = context.viewController(forKey: $0)?.navBarTintColor
        }

        if context.isCancelled {
            let cancelDuration: TimeInterval = context.transitionDuration * Double(context.percentComplete)
            UIView.animate(withDuration: cancelDuration) {
                animations(.from)
            }
        } else {
            let finishDuration: TimeInterval = context.transitionDuration * Double(1 - context.percentComplete)
            UIView.animate(withDuration: finishDuration) {
                animations(.to)
            }
        }
    }
}


