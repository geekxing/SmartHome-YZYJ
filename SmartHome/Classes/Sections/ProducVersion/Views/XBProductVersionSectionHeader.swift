//
//  XBProductVersionSectionHeader.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/25.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBProductVersionSectionHeader: UITableViewHeaderFooterView {
    
    var titleLabel:UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        self.contentView.backgroundColor = UIColor.white
        titleLabel = UILabel()
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel?.numberOfLines = 0;
        titleLabel?.textColor = XB_DARK_TEXT
        contentView.addSubview(titleLabel!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.sizeToFit()
        titleLabel?.left = 33
        titleLabel?.top = 27;
    }
    

}
