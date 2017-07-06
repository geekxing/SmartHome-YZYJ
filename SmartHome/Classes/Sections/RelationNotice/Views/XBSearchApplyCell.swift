//
//  XBSearchApplyCell.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/20.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBSearchApplyCell: XBRelationConcernCell {
    
    static let maxNameLen = CGFloat(150.0*UIRate)
    static let maxEmailLen = CGFloat(95.0*UIRate)
    
    private var cancelButton:XBRoundedButton!
    private var applyButton:XBRoundedButton!
    
    var clickCancelButton:((XBUser) -> ())?
    var clickApplyButton:((XBUser) -> ())?
    
    override func setup() {
        super.setup()
    
        cancelButton = XBRoundedButton.init(selector: #selector(clickCancel(_:)),target:self, title: NSLocalizedString("Cancel", comment: ""))
        applyButton = XBRoundedButton.init(selector: #selector(clickApply(_:)),target:self, title: NSLocalizedString("Request", comment: ""))
        contentView.addSubview(cancelButton)
        contentView.addSubview(applyButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.width = XBSearchApplyCell.maxNameLen
        emailLabel.width = XBSearchApplyCell.maxEmailLen
        emailLabel.left = nameLabel.left
        emailLabel.bottom = avatarView.bottom - 5
        applyButton.right = width - 33
        applyButton.bottom = self.emailLabel.bottom
        cancelButton.right = applyButton.left - 8
        cancelButton.bottom = applyButton.bottom
    }
    
    //MARK: - Action
    @objc private func clickApply(_ btn:UIButton) {
        if clickApplyButton != nil {
            clickApplyButton!(model.user!)
        }
    }
    
    @objc private func clickCancel(_ btn:UIButton) {
        if clickCancelButton != nil {
            clickCancelButton!(model.user!)
        }
    }
    

}
