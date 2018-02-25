//
//  MainTableViewCell.swift
//  YYDeviceScanning
//
//  Created by daoquan on 2018/2/25.
//  Copyright © 2018年 deerdev. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var mac: UILabel!
    @IBOutlet weak var owner: UILabel!
    @IBOutlet weak var name: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setModel(_ info: DeviceInfo, _ nId: Int) {
        mac.text = info.mac
        owner.text = info.owner
        name.text = info.productId
        id.text = "\(nId)"
    }

}
