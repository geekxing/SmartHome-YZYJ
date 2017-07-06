//
//  NSObject+Extension.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/4/6.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import Foundation

extension NSObject {
    
    class func properties_name() -> [String] {
        var count:UInt32 = 0
        let ivars = class_copyIvarList(self, &count)
        var properties_name = [String]()
        for i in 0..<count {
            let ivar = ivars?[Int(i)]
            let ivarName = ivar_getName(ivar!)
            let nName = String(cString: ivarName!)
            properties_name.append(nName)
        }
        return properties_name
    }
    
}
