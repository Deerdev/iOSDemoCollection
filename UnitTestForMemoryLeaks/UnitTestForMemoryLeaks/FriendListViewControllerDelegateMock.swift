//
//  FriendListViewControllerDelegateMock.swift
//  UnitTestForMemoryLeaks
//
//  Created by daoquan on 2017/12/28.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class FriendListViewControllerDelegateMock: NSObject {

}

extension FriendListViewControllerDelegateMock: FriendListViewControllerDelegate {
    func test() {
        print("mock delegate")
    }
}
