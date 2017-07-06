//
//  XBSquareButton.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2016/12/4.
//  Copyright © 2016年 helloworld.com. All rights reserved.
//

import UIKit

class XBSquareButton: UIButton {
    
    let subTitleLabel = UILabel()
    
    var subTitleRatioToImageView:CGFloat = 0.38*UIRate {
        didSet {
            subTitleLabel.height = imageView!.height * (1-subTitleRatioToImageView)
            subTitleLabel.top = imageView!.height * subTitleRatioToImageView
        }
    }
    
    ///从代码加载
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    ///从storyboard里面加载
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        titleLabel?.font = UIFont.systemFont(ofSize: 15)
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 2
        self.setTitleColor(XB_DARK_TEXT, for: .normal)
        
        subTitleLabel.textColor = UIColor.white
        subTitleLabel.numberOfLines = 0
        subTitleLabel.textAlignment = .center
        
        let imageViewH = bounds.height * 2 / 3 * UIRate
        subTitleLabel.width = bounds.width
        subTitleLabel.height = imageViewH * (1-subTitleRatioToImageView)
        subTitleLabel.top = imageViewH * subTitleRatioToImageView
        addSubview(subTitleLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView!.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 2*bounds.height/3)
        if let title = titleLabel!.text {
            var size = (title as NSString).size(attributes: [NSFontAttributeName:titleLabel!.font])
            var fontSize = titleLabel!.font.pointSize
            while size.width > self.width && titleLabel!.adjustsFontSizeToFitWidth {
                fontSize -= 1
                let font = UIFontSize(fontSize)
                size = (title as NSString).size(attributes: [NSFontAttributeName:font])
            }
            titleLabel?.width = size.width
            titleLabel?.height = size.height
        }
        titleLabel!.centerX = self.width * 0.5
        if imageView!.image != nil {
            titleLabel?.top = imageView!.bottom + 4
        } else {
            titleLabel?.bottom = self.height * 0.9
        }
        subTitleLabel.centerX = titleLabel!.centerX
    }

    
}
