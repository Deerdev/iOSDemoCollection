//
//  UserManager.swift
//  UnitTestForMemoryLeaks
//
//  Created by daoquan on 2017/12/28.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class UserManager {
    private var observers = [ObserverWrapper]()
    
    func addObserver(_ observer: UserManagerObserver) {
        let wrapper = ObserverWrapper(observer: observer)
        observers.append(wrapper)
    }
    
    private func notifyObserversOfUserChange(_ user: String) {
        // 收到通知时，处理已经release的observer对象
        observers = observers.filter { wrapper in
            guard let observer = wrapper.observer else {
                return false
            }
            
            observer.userManager(self, userDidChange: user)
            return true
        }
    }
}

private extension UserManager {
    // 包裹weak对象
    struct ObserverWrapper {
        weak var observer: UserManagerObserver?
    }
}
