//
//  XBApplyConcernCell.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/1/16.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBApplyConcernCell: XBRelationConcernCell {
    
    static let maxNameLen = CGFloat(100.0*UIRate)
    static let maxEmailLen = CGFloat(100.0*UIRate)
    
    private var agreeButton:UIButton!
    private var refuseButton:UIButton!
    
    var clickAgreeButton:((XBUser) -> ())?
    var clickRefuseButton:((XBUser) -> ())?
    
    override func setup() {
        super.setup()
        agreeButton = XBRoundedButton.init(selector:#selector(clickAgree(_:)),target:self, title: NSLocalizedString("Approve", comment: ""))
        refuseButton = XBRoundedButton.init(selector: #selector(clickRefuse(_:)),target:self, title: NSLocalizedString("Refuse", comment: ""))
        shadowLineview.isHidden = false
        contentView.addSubview(agreeButton)
        contentView.addSubview(refuseButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarView.top = 0;
        nameLabel.width = XBApplyConcernCell.maxNameLen
        nameLabel.bottom = avatarView.centerY-5
        nameLabel.left = avatarView.right + 8*UIRate
        emailLabel.width = XBApplyConcernCell.maxEmailLen
        emailLabel.top = avatarView.centerY+5
        emailLabel.left = nameLabel.left
        refuseButton.right = width - 25*UIRate
        refuseButton.centerY = avatarView.centerY
        agreeButton.right = refuseButton.left - 8*UIRate
        agreeButton.centerY = avatarView.centerY
    }
    
    //MARK: - Action
    @objc private func clickAgree(_ btn:UIButton) {
        if clickAgreeButton != nil {
            clickAgreeButton!(model.user!)
        }
    }
    
    @objc private func clickRefuse(_ btn:UIButton) {
        if clickRefuseButton != nil {
            clickRefuseButton!(model.user!)
        }
    }

}
