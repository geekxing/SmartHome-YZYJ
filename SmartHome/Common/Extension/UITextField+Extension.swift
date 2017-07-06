//
//  UITextField+Extension.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/4/1.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import Foundation


extension UITextField {
    
    func isBlank() -> Bool {
        if let text = self.text {
           return (text as NSString).length == 0
        }
        return true
    }
    
}
