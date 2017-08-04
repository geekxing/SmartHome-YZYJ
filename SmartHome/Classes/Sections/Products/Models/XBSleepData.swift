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
    ///是否白天段睡眠时长小于1.5h的无效数据
    fileprivate(set) var deleteTagForDay:Bool = false
    ///是否夜晚段睡眠时长小于1.5h的不适用于统计分析的数据
    fileprivate(set) var deleteTagForAnalysis:Bool = false

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
    var score:Int = 0 {
        didSet {
            if self.score < 10 {
               self.score = 10
            } else if self.score > 100 {
                self.score = 100
            }
        }
    }
    
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
        ///分析数据，给模型加上相应标签
        self.setDeleteTag()
    }
    
    
    //返回总的睡眠时长
    func sleepTime() -> Double {
        
        var totalSleep = lightSleepTime + deepSleepTime
        let totalOnBed = outOfBed - goToBed
        ///修正数据部分
        if totalSleep > totalOnBed {
            let scale = totalOnBed / totalSleep
            totalSleep = totalOnBed
            lightSleepTime *= scale
            deepSleepTime *= scale
        }
        return totalSleep / 3600.0
        
    }
    
    private func timeIntevalProperties() -> [String] {
        
        return ["creatTime","date","goToBed","outOfBed","sleepStart",
                "sleepEnd"]
        
    }
    
    override var debugDescription: String {
        
        var des = ""
        for property in myProperties {
            if let value = self.value(forKey: property) {
                des += " \(property) : \(String(describing: value)) "
            }
        }
        return des
        
    }
    
    //MARK: - Private
    
    private func setDeleteTag() {
        let beginH = Date(timeIntervalSince1970: self.goToBed).hour
        let endH = Date(timeIntervalSince1970: self.outOfBed).hour
        let isWhiteDay = (beginH > 10 && endH < 22)
        self.deleteTagForDay = isWhiteDay && (self.sleepTime() < 1.5)
        self.deleteTagForAnalysis = !isWhiteDay && (self.sleepTime() < 1.5)
    }
    
}
