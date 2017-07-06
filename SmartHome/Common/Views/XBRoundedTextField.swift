//
//  XBRoundedTextField.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/20.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBRoundedTextField: UITextField {
    
    override var isEnabled: Bool {
        didSet {
            self.textColor = isEnabled ? self.textColor : UIColor.gray
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColorHex("595757", 1.0).cgColor
        self.backgroundColor = UIColor.white
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.height * 0.5
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let inset = bounds.height * 0.25
        return CGRect(x: inset, y: 0, width: bounds.width-2*inset, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let inset = bounds.height * 0.25
        return CGRect(x: inset, y: 0, width: bounds.width-2*inset, height: bounds.height)
    }

}
