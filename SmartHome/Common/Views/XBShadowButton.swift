//
//  XBShadowButton.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/28.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBShadowButton: UIButton {
    
    lazy var leftShadow = UIImageView(image: UIImage(named: "verticalShadow"))
    
    lazy var rightShadow = UIImageView(image: UIImage(named: "vertiShadow_L"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addShadow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func addShadow() {
        addSubview(leftShadow)
        addSubview(rightShadow)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        leftShadow.width = 10
        leftShadow.left = 0
        leftShadow.top = 0
        rightShadow.width = 10
        rightShadow.right = width
        rightShadow.top = 0
    }

}
