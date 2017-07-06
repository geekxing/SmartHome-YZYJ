//
//  XBRingView.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/3/12.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBRingView: UIView {
    
    var strokeWidth:CGFloat = 0
    var strokeColor:UIColor?
    
    var maxValue:CGFloat = 0
    var increment:CGFloat = 0
    
    let title = NSLocalizedString("Sleep Score", comment: "")
    var titleSize:CGSize = CGSize.zero
    
    var progress:CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleSize = (title as NSString).size(attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: UIRate*14)])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        titleSize = (title as NSString).size(attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: UIRate*14)])
    }
    
    private var ringRect:CGRect {
        let radius = (self.height - self.strokeWidth) * 0.5
        return CGRect(x: strokeWidth*0.5, y: strokeWidth*0.5, width: 2*radius, height: 2*radius)
    }

    override func draw(_ rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
    
        let backGroundPath = UIBezierPath(ovalIn: self.ringRect)
        ctx?.setLineWidth(self.strokeWidth)
        ctx?.setLineCap(CGLineCap.round)
        UIColorHex("edebea", 1).set()
        ctx?.addPath(backGroundPath.cgPath)
        ctx?.strokePath()

        let startA = -Double.pi/2
        let endA   = -Double.pi/2 + Double(self.progress) * Double.pi * 2
        drawArc(startA: CGFloat(startA), endA: CGFloat(endA), color: self.strokeColor!, in: rect, ctx: ctx)
        
        drawText()
    }
    
    func drawArc(startA:CGFloat, endA:CGFloat, color:UIColor, in rect:CGRect, ctx:CGContext?) {
        let center = CGPoint(x: rect.width * 0.5, y: rect.height * 0.5)
        let radius = (self.height - self.strokeWidth) * 0.5
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(startA), endAngle: CGFloat(endA), clockwise: true)
        ctx?.setLineWidth(self.strokeWidth)
        ctx?.setLineCap(.butt)
        color.set()
        ctx?.addPath(path.cgPath)
        ctx?.strokePath()
    }
    
    func drawText() {
        let score = "\(Int(round(self.progress * 100)))" as NSString
        //获取文字的rect
        let textRect = score.boundingRect(with: CGSize(width:70, height:40), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFontSize(40)], context: nil)
        score.draw(in: CGRect(x:(self.width-textRect.width)/2,y:self.height*0.5-37,width:textRect.width,height:textRect.height), withAttributes: [NSFontAttributeName:UIFontSize(40)])
        (title as NSString).draw(at: CGPoint(x:(self.width-titleSize.width)*0.5,y:self.height*0.5+15), withAttributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: UIRate*14)])
    }

}
