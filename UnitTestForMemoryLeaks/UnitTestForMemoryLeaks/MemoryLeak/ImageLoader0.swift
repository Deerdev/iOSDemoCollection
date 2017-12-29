//
//  ImageLoader0.swift
//  UnitTestForMemoryLeaks
//
//  Created by daoquan on 2017/12/29.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class ImageLoader0 {
    var handlerArray = [(UIImage) -> Void]()
    func loadImage(from url: URL,
                   completionHandler: @escaping (UIImage) -> Void) {
        handlerArray.append(completionHandler)
        
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                completionHandler(UIImage())
            }
        }
    }
}

