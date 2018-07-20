//
//  DXTableViewCell.swift
//  DXTableViewWidget
//
//  Created by deer on 2018/7/20.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class DXTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func initCellStyle() {
        textLabel?.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        textLabel?.font = UIFont.systemFont(ofSize: 17)
        detailTextLabel?.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
    }

}
