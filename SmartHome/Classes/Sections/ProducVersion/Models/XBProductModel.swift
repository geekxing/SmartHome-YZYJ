//
//  XBProductModel.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/26.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBProductModel: NSObject {
    
    private(set) var productName:String?
    private(set) var typesn:String?
    private(set) var typeIp:String?
    private(set) var level:String?
    private(set) var deadline:String?

    
    convenience init(productName:String?, typesn:String?, typeIp:String?, level:String?, deadline:String?) {
        self.init()
        self.productName = productName
        self.typesn = typesn
        self.typeIp = typeIp
        self.level = level
        self.deadline = deadline
    }
    
    override var debugDescription: String {
        
        var des = ""
        for str in XBProductModel.properties_name() {
            let value = (self.value(forKey: str) as? String) ?? ""
            let newStr = str + ":" + value + "\n"
            des += newStr
        }
        return des
        
    }
    
}
