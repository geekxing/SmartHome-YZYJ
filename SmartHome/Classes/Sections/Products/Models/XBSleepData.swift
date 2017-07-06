//
//  XBSleepData.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/26.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import SwiftyJSON

class XBSleepData: NSObject {
    
    let myProperties = XBSleepData.properties_name()

    var id:String = ""
    var user:String = ""
    var deviceSN:String = ""
    var creatTime:Double = 0
    var date:Double = 0
    var goToBed:Double = 0
    var outOfBed:Double = 0
    var sleepStart:Double = 0
    var sleepEnd:Double = 0
    var lightSleepTime:Double = 0
    var deepSleepTime:Double = 0
    var avgHeart:Int = 0
    var avgBreath:Int = 0
    var outNum:Int = 0
    var turnNum:Int = 0
    var score:Int = 0
    
    var selected = false
    
    func add(_ json:JSON) {
        let timeGroup = timeIntevalProperties()
        for (key,subJson):(String, JSON) in json {
            if !myProperties.contains(key) {
                continue
            }
            var value:Any?
            if timeGroup.contains(key) {
                value = (subJson.rawValue as! Double) / 1000.0
            }else {
                value = subJson.stringValue
            }
            self.setValue(value, forKey: key)
        }
    }
    
    
    //返回总的睡眠时长
    func sleepTime() -> Double {
        
        let total = (lightSleepTime + deepSleepTime)
        return total / 3600.0
        
    }
    
    private func timeIntevalProperties() -> [String] {
        
        return ["creatTime","date","goToBed","outOfBed","sleepStart",
                "sleepEnd"]
        
    }
    
    override var debugDescription: String {
        
        var des = ""
        for property in myProperties {
            des += " \(property) : \(String(describing: self.value(forKey: property))) "
        }
        return des
        
    }
    
}
