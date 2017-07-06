//
//  XBMyConcernCell.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/1/16.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBMyConcernCell: XBConcernMeCell {
    
    var arrowButton:UIButton!
    var checkRealTime:((XBUser,XBProductType) -> ())?
    var checkHealth:((XBUser,XBProductType) -> ())?
    
    override var model:XBRelationConcernModel! {
        didSet {
            arrowButton.isSelected = self.model.open
            //目前只启用智能床垫
            if model.open {
                bedView.sn = model.user.Device().first
            }
            for view in productViews {
                view.isHidden = !model.open
            }
        }
    }
    
    private let bedView = XBCheckProductView(NSLocalizedString("Mattress Pad", comment: ""))
    private let pillowView = XBCheckProductView(NSLocalizedString("Pillow", comment: ""))
    private let ringView = XBCheckProductView(NSLocalizedString("Bracelet", comment: ""))
    
    var productViews:[XBCheckProductView]!
    
    var clickArrowButton:(()->())?
    
    override func setup() {
        super.setup()
        
        arrowButton = UIButton.init(image: UIImage(named:"arrowDown"), backImage: nil, color: nil, target: self, sel: #selector(clickArrow(_:)), title: "")
        arrowButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0)
        arrowButton.setImage(UIImage(named:"arrowUp"), for: .selected)
        productViews = [bedView, pillowView, ringView]
        for view in productViews {
            view.isHidden = true
            configProductView(view)
            contentView.addSubview(view)
        }
        contentView.addSubview(arrowButton)
        
        let tapToOpen = UITapGestureRecognizer(target: self, action: #selector(clickArrow(_:)))
        self.addGestureRecognizer(tapToOpen)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        arrowButton.width = 44;
        arrowButton.height = 44;
        arrowButton.left = 2
        arrowButton.centerY = avatarView.centerY;
        for (index, view) in productViews.enumerated() {
            let size = view.sizeThatFits(CGSize(width: self.width, height: 20))
            view.frame = CGRect(x: 0, y: 71 + CGFloat(index*40), width: size.width, height: 20)
            view.right = cancelConcernButton.centerX
        }
    }
    
    //MARK: - Action
    @objc private func clickArrow(_ btn:UIButton) {
        self.model.open = !self.model.open
        if self.clickArrowButton != nil {
            self.clickArrowButton!()
        }
    }
    
    func configProductView(_ view:XBCheckProductView) {
        
        let idx = productViews.index(of: view)!
        let type = XBProductType(rawValue:idx)! //获取产品类型
        
        view.clickRealTimeButton = {
            if self.checkRealTime != nil {
                self.checkRealTime!(self.model.user,type)
            }
        }
        view.clickHealthButton = {
            if self.checkHealth != nil {
                self.checkHealth!(self.model.user,type)
            }
        }
        
    }

}
