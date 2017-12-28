//
//  presentSegue.swift
//  VCTransitionTest
//
//  Created by daoquan on 2017/11/27.
//  Copyright © 2017年 deerdev. All rights reserved.
//

import UIKit

class PresentSegue: UIStoryboardSegue {

    override func perform() {
        self.source.present(self.destination, animated: false, completion: nil)
    }
}
