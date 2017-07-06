//
//  XBTextField.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/20.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: font!.pointSize, width: bounds.width, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: font!.pointSize, width: bounds.width, height: bounds.height)
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        
        return CGRect(x: self.width - 40, y: font!.pointSize, width: 40, height: 40)
    }

}
