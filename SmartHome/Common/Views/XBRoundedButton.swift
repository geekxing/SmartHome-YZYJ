//
//  XBRoundedButton.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/20.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBRoundedButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience init(selector:Selector, target:AnyObject, title:String) {
        self.init(selector:selector, target:target, font:11, title:title)
    }
    
    convenience init(selector:Selector, target:AnyObject, font:CGFloat, title:String) {
        self.init()
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: font)
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
        self.sizeToFit()
        self.addTarget(target, action: selector, for: .touchUpInside)
        self.width += 22*UIRate
        self.height += font
    }
    
    func setup() {
        
        self.setBackgroundImage(UIImage.imageWith(RGBA(r: 136, g: 132, b: 128, a: 1)), for: .normal)
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.minimumScaleFactor = 0.5
        self.layer.masksToBounds = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.height * 0.5
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let buttonFrame = self.frame
        let newRect = buttonFrame.insetBy(dx: -5, dy: -5)
        if newRect.contains(point) {
            return true
        }
        return super.point(inside: point, with: event)
    }
    
    
}
