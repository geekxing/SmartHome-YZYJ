//
//  XBSplitView.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/20.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBSplitView: UIView {
    
    static let buttonH = CGFloat(74.0)
    var buttonW:CGFloat = 0
    var buttons = [XBShadowButton]()
    
    var currentIndex:Int = 0 {
        didSet {
            tapBtn(buttons[currentIndex])
        }
    }
    
    var cornerRadius = CGFloat(0)
    
    private var titles = [String]()
    
    private var previousButton:UIButton?
    
    var tapSplitButton:((Int)->())?
    
    convenience init(titles:[String]) {
        self.init()
        self.titles = titles
        buttonW = SCREEN_WIDTH/CGFloat(self.titles.count)
        setup()
    }
    
    private func setup() {
        
        self.backgroundColor = RGBA(r: 232, g: 234, b: 235, a: 1.0)
        for (index, title) in titles.enumerated() {
            let button = setupButton(title: title)
            button.tag = index
            buttons.append(button)
            addSubview(button)
        }
        
        tapBtn(buttons[0])
        
    }
    
    private func setupButton(title:String!) -> XBShadowButton {
        
        let button = XBShadowButton.init(image: nil, backImage: UIImage.imageWith(RGBA(r: 196, g: 190, b: 183, a: 1.0)), color: nil, target: self, sel: #selector(tapBtn(_:)), title: title)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIRate*20)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.setBackgroundImage(UIImage.imageWith(UIColor.white), for: .selected)
        button.setBackgroundImage(UIImage.imageWith(RGBA(r: 196, g: 190, b: 183, a: 1.0)), for: .highlighted)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(XB_DARK_TEXT, for: .selected)
        button.layer.masksToBounds = true
        
        return button
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for (index,button) in buttons.enumerated() {
            button.frame = CGRect(x: CGFloat(index)*buttonW, y: 0, width: buttonW, height: XBSplitView.buttonH)
            button.layer.cornerRadius = self.cornerRadius
        }
    }
    
    //MARK: - Private
    @objc private func tapBtn(_ button:UIButton) {
        
        previousButton?.isSelected = false
        button.isSelected = true
        previousButton = button
        addShadow()
        if self.tapSplitButton != nil {
            self.tapSplitButton!(button.tag)
        }
        
    }
    
    private func addShadow() {
        
        let nowIndex = previousButton!.tag
        for (index, button) in buttons.enumerated() {
            let shadowBtn = button as XBShadowButton
            if nowIndex == index {
                shadowBtn.leftShadow.isHidden = true
                shadowBtn.rightShadow.isHidden = true
            } else if nowIndex > index {
                shadowBtn.leftShadow.isHidden = true
                shadowBtn.rightShadow.isHidden = false
            } else {
                shadowBtn.leftShadow.isHidden = false
                shadowBtn.rightShadow.isHidden = true
            }
        }
    }
    

}
