//
//  XBRealDataTableCell.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/3/13.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBRealDataTableCell: UITableViewCell {
    
    var event:Int = 0
    var shouldEnableEcgDisplay = false {
        didSet {
            contentView.addSubview(self.ecgView)
        }
    }
    var valueLabel:UILabel!
    private var shadowLineview:UIImageView!
    lazy var ecgView:XBEcgView = {
       return XBEcgView()
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup() {
        
        self.selectionStyle = .none
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        self.textLabel?.textColor = XB_DARK_TEXT
        self.textLabel?.textAlignment = .left
        self.textLabel?.numberOfLines = 0
        shadowLineview = UIImageView(image: UIImage(named: "horizontalShadow"))
        valueLabel = UILabel()
        valueLabel.numberOfLines = 0
        valueLabel.textAlignment = .center
        contentView.addSubview(shadowLineview)
        contentView.addSubview(valueLabel)
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        self.imageView?.sizeToFit()
        self.imageView?.left = UIRate * 33
        self.imageView?.top  = 41
        
        textLabel?.sizeToFit()
        textLabel?.left = 10 * UIRate + self.imageView!.right
        textLabel?.centerY = self.imageView!.centerY
    
        valueLabel.width = 50
        valueLabel.height = self.height
        valueLabel.centerX = self.width - (UIRate * 33 - valueLabel.width * 0.05)
        valueLabel.centerY = self.imageView!.centerY
        
        if self.shouldEnableEcgDisplay {
            ecgView.width = valueLabel.left - textLabel!.right - 40
            ecgView.height = 80
            ecgView.left = textLabel!.right + 20
            ecgView.centerY = self.imageView!.centerY
        }
        
        shadowLineview.width = self.width
        shadowLineview.bottom = self.height
        shadowLineview.left = 0
        
    }

}
