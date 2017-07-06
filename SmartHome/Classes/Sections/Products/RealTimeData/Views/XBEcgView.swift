//
//  XBEcgView.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/3/13.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBEcgView: UIView {
    
    var ecgLine:CALayer?
    
    var speed:Float = 1.0 {
        didSet {
            animation()
        }
    }
    
    let pointYs:[CGFloat] =
        [0,0,0,0,0,2,-10,0,-2,5,-8,0,0,0,0,0,2,-10,0,-2,5,-8,0,0,0,0,0,2,-10,0,-2,5,-8]
    
    var xScale:CGFloat = 0
    var moveAnim:CABasicAnimation?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if xScale == 0 {
            drawLayer()
        }
        xScale = width / CGFloat( pointYs.count )
    }
    
    private func setup() {
        
        self.backgroundColor = UIColor.white
        NotificationCenter.default.addObserver(self, selector: #selector(changeDrawingMode(_:)), name: Notification.Name.init(rawValue: XBDrawFrequecyDidChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
    }
    
    @objc private func changeDrawingMode(_ aNote:Notification) {
        self.speed = (aNote.userInfo!["obj"] as! Float) / 100.0
    }
    
    //MARK: - Notification
    
    func didBecomActive() {
        if let ecg = ecgLine {
            XBAnimator.resumeAnim(for: ecg, with: 1)
        }
        
    }
    
    func didEnterBackground() {
        
        XBAnimator.pauseAnim(for: ecgLine)
        
    }
    
    //MARK: - Draw ECG Graph 
    
    func drawLayer() {
        
        let r = CAReplicatorLayer()
        r.bounds = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        r.position = CGPoint(x: width / 2, y: height / 2)
        
        self.layer.addSublayer(r)
        
        let bar = CALayer()
        bar.bounds = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        bar.position = CGPoint(x: width / 2, y: height / 2)
        bar.delegate = self
        bar.setNeedsDisplay()
        ecgLine = bar
        
        r.addSublayer(bar)
        
        r.instanceCount = 2
        r.instanceTransform = CATransform3DMakeTranslation(width , 0.0, 0.0)
        r.masksToBounds = true
        
        let move = CABasicAnimation(keyPath: "position.x")
        move.toValue = bar.position.x - width
        move.duration = 1.5
        move.speed = 0
        move.repeatCount = Float.infinity
        move.isRemovedOnCompletion = false
        bar.add(move, forKey: "move")
        moveAnim = move
        
    }
    
    func animation() {
        
        if let ecg = ecgLine {
            
            ecg.removeAnimation(forKey: "move")
            moveAnim?.speed = speed
            ecg.add(moveAnim!, forKey: "move")
        
        }
        
    }
    
    //MARK: -
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        
        ctx.setLineWidth(2)
        ctx.setLineJoin(.round)
        ctx.setStrokeColor(UIColor.black.cgColor)
        
        let path = UIBezierPath()
        
        let startY = pointYs.first!
        path.move(to: CGPoint(x: 0, y: startY))
        
        for i in 1..<pointYs.count {
            path.addLine(to: CGPoint(x: CGFloat(i)*xScale, y: pointYs[i]))
        }
        
        path.addLine(to: CGPoint(x: width, y: 0))
        
        var t = CGAffineTransform(a: 1.0, b: 0, c: 0, d: 2, tx: 0, ty: layer.bounds.height * 0.5)
        let cgPath = path.cgPath.copy(using: &t)
        
        ctx.setAllowsAntialiasing(true)
        ctx.setShouldAntialias(true)
        ctx.addPath(cgPath!)
        ctx.strokePath()
        
    }
    
    
}
