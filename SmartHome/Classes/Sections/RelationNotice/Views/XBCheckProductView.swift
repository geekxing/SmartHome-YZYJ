//
//  XBCheckProductView.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/25.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBCheckProductView: UIView {
    
    var productLabel:UILabel!
    var sn:String? {
        didSet {
            realTimeDataButton.isEnabled = sn != nil
            healCareButton.isEnabled = sn != nil
        }
    }
    private var realTimeDataButton:UIButton!
    private var healCareButton:UIButton!
    
    var clickRealTimeButton:(() -> ())?
    var clickHealthButton:(() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience init(_ name:String) {
        self.init()
        self.productLabel.text = name
    }
    
    private func setup() {
        productLabel = UILabel()
        productLabel.textAlignment = .right
        productLabel.font = UIFont.boldSystemFont(ofSize: 14)
        productLabel.textColor = XB_DARK_TEXT
        
        let label = UILabel()
        label.text = "Mattress Pad"
        label.sizeToFit()
        productLabel.width = label.width
        productLabel.height = label.height
        
        realTimeDataButton = XBRoundedButton(selector: #selector(clickRealTime(_:)),target:self, title: NSLocalizedString("Real-time Data", comment: ""))
        healCareButton = XBRoundedButton(selector: #selector(clickHealCare(_:)),target:self, title: NSLocalizedString("Health Archives", comment: ""))
        realTimeDataButton.isEnabled = false
        healCareButton.isEnabled = false
        realTimeDataButton.titleLabel?.numberOfLines = 1
        healCareButton.titleLabel?.numberOfLines = 1
        addSubview(productLabel)
        addSubview(realTimeDataButton)
        addSubview(healCareButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        productLabel.left = 0
        productLabel.centerY = height * 0.5
        realTimeDataButton.height = 20
        realTimeDataButton.left = productLabel.right + UIRate*20
        realTimeDataButton.centerY = height * 0.5
        healCareButton.height = 20;
        healCareButton.left = realTimeDataButton.right+10
        healCareButton.centerY = height * 0.5
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var width = productLabel.width + 30 + healCareButton.width + realTimeDataButton.width
        if width > size.width-40 {
            width = size.width-40
            healCareButton.width = width/3 - 10
            realTimeDataButton.width = width/3 - 10
        }
        return CGSize(width: width, height: healCareButton.height)
    }
    
    //MARK: - Action
    @objc private func clickRealTime(_ btn:UIButton) {
        if clickRealTimeButton != nil {
            clickRealTimeButton!()
        }
        
    }
    
    @objc private func clickHealCare(_ btn:UIButton) {
        if clickHealthButton != nil {
            clickHealthButton!()
        }
    }
    
}
