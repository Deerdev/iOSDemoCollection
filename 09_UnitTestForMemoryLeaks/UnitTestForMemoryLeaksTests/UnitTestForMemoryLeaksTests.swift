//
//  UnitTestForMemoryLeaksTests.swift
//  UnitTestForMemoryLeaksTests
//
//  Created by daoquan on 2017/12/28.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import XCTest
@testable import UnitTestForMemoryLeaks

// MARK: - Memory leaks
class FriendListViewControllerTests0: XCTestCase {
    func testDelegateNotRetained() {
        let controller = FriendListViewController0()
        
        // 创建一个强引用的delegate
        var delegate = FriendListViewControllerDelegateMock()
        controller.delegate = delegate
        
        // 重新赋值delegate，同时这将导致原本的delegate被释放
        // 因此，view controller的delegate会被置为 nil
        delegate = FriendListViewControllerDelegateMock()
        XCTAssertNil(controller.delegate)
    }
}

class UserManagerTests0: XCTestCase {
    func testObserversNotRetained() {
        let manager = UserManager0()
        
        // 创建一个强引用的observer，加入到UserManager中
        // 同时创建一个弱引用observer来检查原始observer的释放
        var observer = UserManagerObserverMock()
        weak var weakObserver = observer
        manager.addObserver(observer)
        
        // 通过重新给observer赋值，我们期望让weakObserver等于nil
        // 因为observers不应该被强应用
        observer = UserManagerObserverMock()
        XCTAssertNil(weakObserver)
    }
}

class ImageLoaderTests0: XCTestCase {
    func testCompletionHandlersRemoved() {
        let myExpectation = expectation(description: "retain")
        // 创建一个对象，可以是任意类型；同时创建一个对应的强&弱引用
        var object = NSObject()
        weak var weakObject = object
        let url = URL(fileURLWithPath: "image")
        
        let loader = ImageLoader0()
        loader.loadImage(from: url) { [object] image in
            // 使用一个捕获列表捕获变量【使用捕获列表[object]捕获对象是为了使用值捕获（捕获当前值，后续被外部修改不影响），而不是被指针捕获（被外部修改会影响内部变量的值）】
            _ = object
            print("closure is finished!")
            myExpectation.fulfill()
        }
        
        // 把强引用的变量重新赋值，弱引用应该会被置为nil
        // 因为此时闭包已经运行完，并且释放
        object = NSObject()
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
            XCTAssertNil(weakObject)
        }
    }
}

// MARK: - Avoid Memory Leaks
class FriendListViewControllerTests: XCTestCase {
    func testDelegateNotRetained() {
        let controller = FriendListViewController()
        
        // 创建一个强引用的delegate
        var delegate = FriendListViewControllerDelegateMock()
        controller.delegate = delegate
        
        // 重新赋值delegate，同时这将导致原本的delegate被释放
        // 因此，view controller的delegate会被置为 nil
        delegate = FriendListViewControllerDelegateMock()
        XCTAssertNil(controller.delegate)
    }
}

class UserManagerTests: XCTestCase {
    func testObserversNotRetained() {
        let manager = UserManager()
        
        // 创建一个强引用的observer，加入到UserManager中
        // 同时创建一个弱引用observer来检查原始observer的释放
        var observer = UserManagerObserverMock()
        weak var weakObserver = observer
        manager.addObserver(observer)
        
        // 通过重新给observer赋值，我们期望让weakObserver等于nil
        // 因为observers不应该被强应用
        observer = UserManagerObserverMock()
        XCTAssertNil(weakObserver)
    }
}

class ImageLoaderTests: XCTestCase {
    func testCompletionHandlersRemoved() {
        let myExpectation = expectation(description: "retain")
        // 创建一个对象，可以是任意类型；同时创建一个对应的强&弱引用
        var object = NSObject()
        weak var weakObject = object
        let url = URL(fileURLWithPath: "image")
        
        let loader = ImageLoader()
        loader.loadImage(from: url) { [object] image in
            // 使用一个捕获列表捕获变量【使用捕获列表[object]捕获对象是为了使用值捕获（捕获当前值，后续被外部修改不影响），而不是被指针捕获（被外部修改会影响内部变量的值）】
            _ = object
            print("closure is finished!")
            myExpectation.fulfill()
        }

        // 把强引用的变量重新赋值，弱引用应该会被置为nil
        // 因为此时闭包已经运行完，并且释放
        object = NSObject()

        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNil(error)
            XCTAssertNil(weakObject)
        }
    }
}
