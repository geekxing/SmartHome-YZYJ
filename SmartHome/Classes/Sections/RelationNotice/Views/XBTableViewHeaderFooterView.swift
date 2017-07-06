//
//  XBTableViewHeaderFooterView.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/24.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBTableViewHeaderFooterView: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.contentView.backgroundColor = UIColor.white
        self.textLabel?.font = UIFont.systemFont(ofSize: 18)
        self.textLabel?.numberOfLines = 0;
        self.textLabel?.textColor = XB_DARK_TEXT
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.left = 25
        self.textLabel?.top = 23;
    }
    
}
