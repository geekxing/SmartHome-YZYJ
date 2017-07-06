//
//  XBRelationConcernCell.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/1/16.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBRelationConcernCell: UITableViewCell {
    
    var avatarView:UIImageView!
    var nameLabel:UILabel!
    var emailLabel:UILabel!
    var shadowLineview:UIImageView!
    
    var model:XBRelationConcernModel! {
        didSet {
            let user = model.user!
            avatarView.setHeader(url: user.image, uid:user.email)
            nameLabel.text = user.name ?? user.Name()
            nameLabel.sizeToFit()
            emailLabel.text = user.email!
            emailLabel.sizeToFit()
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
        self.selectionStyle = .none
        avatarView = UIImageView(frame: CGRect.zero)
        avatarView.isUserInteractionEnabled = true
        nameLabel = UILabel()
        nameLabel.font = UIFontSize(16)
        nameLabel.textColor = XB_DARK_TEXT
        emailLabel = UILabel()
        emailLabel.font = UIFontSize(11)
        emailLabel.textColor = UIColorHex("595757", 1.0)
        shadowLineview = UIImageView(image: UIImage(named: "horizontalShadow"))
        shadowLineview.isHidden = true
        contentView.addSubview(avatarView!)
        contentView.addSubview(nameLabel!)
        contentView.addSubview(emailLabel!)
        contentView.addSubview(shadowLineview!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var nameLabelToHeaderMargin = 0.0
        if (avatarView.image != nil) {
            avatarView.width = 54*UIRate
            avatarView.height = 54*UIRate
            nameLabelToHeaderMargin = 8
        } else {
            avatarView.sizeThatFits(CGSize.zero)
            nameLabelToHeaderMargin = 0
        }
        avatarView.x = 33*UIRate
        avatarView.centerY = height * 0.5
        
        nameLabel.left = avatarView!.right + CGFloat(nameLabelToHeaderMargin)
        nameLabel.bottom = avatarView.height * 0.5
        
        shadowLineview.width = self.width
        shadowLineview.height = 8.0;
        shadowLineview.bottom = self.height
        shadowLineview.left = 0
        
    }
    
}
