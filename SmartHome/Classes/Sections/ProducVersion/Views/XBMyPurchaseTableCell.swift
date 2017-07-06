//
//  XBMyPurchaseTableCell.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/25.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBMyPurchaseTableCell: UITableViewCell {
    
    private var proNameLabel:UILabel!
    private var vipLabel:UILabel!
    private var purchaseButton:XBRoundedButton!
    
    var model:XBProductModel? {
        didSet {
            
            proNameLabel.text = model?.productName
            proNameLabel.sizeToFit()
            if XBUserManager.shared.loginUser()!.Device().first != nil && model?.productName == NSLocalizedString("Smart Mattress Pad", comment: "") {
                purchaseButton.isEnabled = true
                proNameLabel.textColor = XB_DARK_TEXT
                vipLabel.textColor = UIColorHex("8a847f", 1.0)
            } else {
                purchaseButton.isEnabled = false
                proNameLabel.textColor = UIColorHex("8a847f", 1.0)
                vipLabel.textColor = UIColorHex("8a847f", 0.6)
            }
            
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        proNameLabel = UILabel()
        proNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        proNameLabel.textColor = XB_DARK_TEXT
        vipLabel = UILabel()
        vipLabel.font = UIFont.boldSystemFont(ofSize: 14)
        vipLabel.textColor = UIColorHex("8a847f", 1.0)
        vipLabel.text = NSLocalizedString("*Advanced Version", comment: "")
        vipLabel.sizeToFit()
        purchaseButton = XBRoundedButton.init(selector: #selector(purchase(_:)), target: self, font:19, title: NSLocalizedString("Renewal\nFee", comment: ""))
        purchaseButton.isEnabled = false
        purchaseButton.titleLabel?.adjustsFontSizeToFitWidth = true
        purchaseButton.titleLabel?.numberOfLines = 2
        purchaseButton.titleLabel?.minimumScaleFactor = 0.5
        addSubview(proNameLabel)
        addSubview(vipLabel)
        addSubview(purchaseButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        proNameLabel.left = 33
        proNameLabel.centerY = height * 0.5
        
        vipLabel.left = proNameLabel.left
        vipLabel.top = proNameLabel.bottom
        
        purchaseButton.height = 35
        purchaseButton.width = 77
        purchaseButton.right = width - 33
        purchaseButton.centerY = height * 0.5
        
    }
    
    //MARK: - Private
    @objc private func purchase(_ btn:UIButton) {
        
    }
    
    
}
