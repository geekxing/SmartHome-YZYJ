//
//  NSString+Extension.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/4/4.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import Foundation

extension String {
    
    func base64Encoding() -> String? {
        
        return self.data(using: .utf8)?.base64EncodedString()
        
    }
    
    func isChinese() -> Bool {
        
        let match = "^[\\u4e00-\\u9fa5]"
        let predicate = NSPredicate(format: "SELF matches %@", match)
        return predicate.evaluate(with:self)
        
    }

}
