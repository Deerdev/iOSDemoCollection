//
//  AddDeviceTableViewCell.swift
//  YYDeviceScanning
//
//  Created by daoquan on 2018/2/24.
//  Copyright © 2018年 deerdev. All rights reserved.
//

import UIKit

protocol AddDeviceTableViewCellDelegate: NSObjectProtocol {
    func scanSnNumber()
    func scanMacAddress()
    func macTextDetect()
}

class AddDeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var trailingToScan: NSLayoutConstraint!
    @IBOutlet weak var trailingToCell: NSLayoutConstraint!
    @IBOutlet weak var scanbtn: UIButton!
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var title: UILabel!

    @IBOutlet weak var textScanBtn: UIButton!
    weak var delegate: AddDeviceTableViewCellDelegate?
    private var cellType: CellType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        inputText.delegate = self
    }

    @IBAction func scanClick(_ sender: UIButton) {
        guard let type = cellType else { return }
        if type == .sn {
            delegate?.scanSnNumber()
        } else if type == .mac {
            delegate?.scanMacAddress()
        }
    }
    @IBAction func textDetectClicked(_ sender: UIButton) {
        delegate?.macTextDetect()
    }

    func setModel(_ model: cellModel?) {
        guard let model = model else {
            return
        }

        scanbtn.isHidden = !model.isNeedScan
        textScanBtn.isHidden = true
        var titleStr = ""
        switch model.cell {
        case .device:
            titleStr = "型号:"
        case .person:
            titleStr = "归属:"
        case .sn:
            titleStr = "S/N:"
        case .mac:
            titleStr = "MAC:"
            textScanBtn.isHidden = false
        }
        cellType = model.cell
        title.text = titleStr
        inputText.placeholder = model.placeHold
        if model.isNeedScan {
            trailingToCell.isActive = false
            trailingToScan.isActive = true
        } else {
            trailingToCell.isActive = true
            trailingToScan.isActive = false
        }

        if let text = model.text {
            inputText.text = text
        }
        setNeedsLayout()
    }

    func setSnNumber(_ str: String?) {
        guard let type = cellType else { return }
        if type == .sn {
            inputText.text = str
        }
    }

    func setMacAddress(_ str: String?) {
        guard let type = cellType else { return }
        if type == .mac {
            inputText.text = str
        }
    }
}

extension AddDeviceTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 关闭键盘
        endEditing(true)
        return true
    }
}
