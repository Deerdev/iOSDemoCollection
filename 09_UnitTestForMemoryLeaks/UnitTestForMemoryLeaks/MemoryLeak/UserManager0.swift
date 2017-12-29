//
//  UserManager.swift
//  UnitTestForMemoryLeaks
//
//  Created by daoquan on 2017/12/28.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class UserManager0 {
    private var observers = [UserManagerObserver]()
    
    func addObserver(_ observer: UserManagerObserver) {
        observers.append(observer)
    }
}

class UserManagerObserver: NSObject {
    func userManager(_ user: UserManager, userDidChange userName: String) {
    }
}

class UserManagerObserverMock: UserManagerObserver {
}
