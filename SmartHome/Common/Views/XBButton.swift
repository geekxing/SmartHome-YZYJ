//
//  XBButton.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/3/24.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBButton: UIButton {

    var xb_imageView:UIImageView!
    var xb_label:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        xb_imageView = UIImageView()
        xb_label = UILabel()
        addSubview(xb_imageView)
        addSubview(xb_label)
    }
    
    
}
