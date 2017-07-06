//
//  XBAlertView.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/26.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBAlertView: UIView {
    
    static let labelGap:CGFloat = 10
    
    private(set) var title:String?
    private(set) var message:String?
    
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private var leftButton:XBRoundedButton?
    private var rightButton:XBRoundedButton?
    
    var clickBtnBlock:((Int)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience init(title:String?, message:String?) {
        self.init()
        self.title = title
        self.message = message
        setData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let titleText = titleLabel.text {
            let rect = (titleText as NSString).boundingRect(with: CGSize(width: self.width - XBAlertView.labelGap, height: CGFloat.infinity), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName:titleLabel.font], context: nil)
            titleLabel.width = rect.width
            titleLabel.height = rect.height
        }
        
        self.height = 176 + titleLabel.height
        titleLabel.top = 50*UIRate
        titleLabel.centerX = width * 0.5
        leftButton?.left = 38 * UIRate
        leftButton?.bottom = height - 44
        rightButton?.right = width - 38*UIRate
        rightButton?.bottom = leftButton!.bottom
        
    }
    
    //MARK: - Setup 
    
    private func setup() {
        
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = XB_DARK_TEXT
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        
        leftButton = commonInitButton(tag: 0, title: NSLocalizedString("ALERTDONE", comment: ""))
        rightButton = commonInitButton(tag: 1, title: NSLocalizedString("ALERTCANCEL", comment: ""))
    }
    
    private func commonInitButton(tag:Int, title:String) -> XBRoundedButton {
        let btn = XBRoundedButton(selector: #selector(clickBtn(_:)),
                                     target: self,
                                     font: 18,
                                     title: title)
        btn.tag = tag
        btn.width = 92
        btn.height = 38
        addSubview(btn)
        return btn
    }
    
    //MARK: - Data
    
    private func setData() {
        titleLabel.text = title
    }
    
    //MARK: - Action
    @objc private func clickBtn(_ btn:UIButton) {
        if (self.clickBtnBlock != nil) {
            self.clickBtnBlock!(btn.tag)
        }
    }
    

}
