//
//  XBSliderView.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/3/13.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBSliderView: UIView {
    
    var trackWidth:CGFloat = 1
    var leftTrackColor:UIColor?
    var rightTrackColor:UIColor?
    var increment:CGFloat = 0
    
    var maxValue:CGFloat = 0
    var progress:CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    let thumbnailButton = XBSquareButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        thumbnailButton.subTitleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        thumbnailButton.subTitleLabel.textColor = UIColor.white
        thumbnailButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        thumbnailButton.left = 0
        addSubview(thumbnailButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnailButton.subTitleLabel.frame = CGRect(x: 0, y: 0, width: self.height, height: self.height)
        thumbnailButton.width = self.height
        thumbnailButton.height = self.height * 1.5
        thumbnailButton.top = 0
    }
    
    override func draw(_ rect: CGRect) {
        
        let backGroundPath = UIBezierPath(roundedRect: CGRect(x: 0, y: (self.height - trackWidth)/2, width:self.width, height:trackWidth), cornerRadius: trackWidth * 0.5)
        rightTrackColor?.set()
        backGroundPath.fill()
        
        let progressLen = self.width * progress
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: (self.height - trackWidth)/2, width:progressLen, height:trackWidth), cornerRadius: trackWidth * 0.5)
        leftTrackColor?.set()
        path.fill()
        
        if progressLen >= thumbnailButton.width / 2 {
            thumbnailButton.centerX = self.width * progress
        }
    }

}
