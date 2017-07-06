//
//  XBConcernMeCell.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/1/16.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBConcernMeCell: XBRelationConcernCell {
    
    static let maxNameLen = CGFloat(100.0*UIRate)
    
    var cancelConcernButton:UIButton!
    var clickCancelButton:((XBUser)->())?

    override func setup() {
        super.setup()
        cancelConcernButton = UIButton(image: UIImage(named:"trashbin"), backImage: nil, color: nil, target: self, sel: #selector(clickCancelConcern(_:)), title: "")
        cancelConcernButton.width = 44
        cancelConcernButton.height = 44
        cancelConcernButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
        contentView.addSubview(cancelConcernButton)
        shadowLineview.isHidden = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarView.top = 0;
        nameLabel.width = XBConcernMeCell.maxNameLen
        nameLabel.centerY = avatarView.centerY
        nameLabel.left = avatarView.right + 8*UIRate
        cancelConcernButton.right = width
        cancelConcernButton.centerY = avatarView.centerY
        emailLabel.width = cancelConcernButton.left - nameLabel.right - 10
        emailLabel.centerY = avatarView.centerY
        emailLabel.left = nameLabel.right
    }
    
    //MARK: - Action
    @objc private func clickCancelConcern(_ btn:UIButton) {
        if clickCancelButton != nil {
            clickCancelButton!(model.user!)
        }
    }
}
