//
//  UIButton.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2016/12/4.
//  Copyright © 2016年 helloworld.com. All rights reserved.
//

import Foundation

extension UIButton  {
    
    convenience init(image:UIImage?, backImage:UIImage?, color:UIColor?, target:Any, sel:Selector, title:String?) {
        self.init()
        self.setTitle(title, for: .normal)
        self.setImage(image, for: .normal)
        self.setBackgroundImage(backImage, for: .normal)
        self.addTarget(target, action: sel, for: .touchUpInside)
        if (color != nil) {
            self.backgroundColor = color
        }
    }
}
