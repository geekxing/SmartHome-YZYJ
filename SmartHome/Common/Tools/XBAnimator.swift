//
//  XBAnimator.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/4/12.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBAnimator: NSObject {
    
    class func pauseAnim(for layer:CALayer?) {
        
        let pauseTime = layer?.convertTime(CACurrentMediaTime(), from: nil)
        layer?.speed = 0
        layer?.timeOffset = pauseTime!
        
    }
    
    class func resumeAnim(for layer:CALayer, with speed:Float) {
        
        let pauseTime = layer.timeOffset
        layer.speed = speed
        layer.timeOffset = 0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), to: nil) - pauseTime
        layer.beginTime = timeSincePause
        
    }

}
