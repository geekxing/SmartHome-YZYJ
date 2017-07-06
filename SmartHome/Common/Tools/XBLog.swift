//
//  XBLog.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/4/6.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import CocoaLumberjack

class XBLog: NSObject {
    
    /**
     配置DDLog相关参数
     */
    class func configDDLog() {
        //让日志只在debug时输出
        #if DEBUG
            defaultDebugLevel = .verbose
        #else
            defaultDebugLevel = .off
        #endif
        //添加发送日志语句到苹果的日志系统
        DDLog.add(DDASLLogger.sharedInstance)
        //添加发送日志语句到Xcode控制台
        DDLog.add(DDTTYLogger.sharedInstance)
        //允许控制台带颜色
        DDTTYLogger.sharedInstance.colorsEnabled = true
        //设置Info下为蓝色
        DDTTYLogger.sharedInstance.setForegroundColor(UIColor.blue, backgroundColor: UIColor.white, for: .info)
    }
    
    /**
     得到输出的字符串的格式
     
     - parameter message:  日志消息的主题
     - parameter file:     日志消息所在的文件，方便调试定位用
     - parameter function: 日志消息所在的方法，方便调试定位用
     - parameter line:     日志消息所在的方法中的行数，方便调试定位用
     
     - returns: 返回输出的日志字符串
     */
    class func getMessage(_ message: String, file: String , function: String , line: UInt ) -> String {
        //初始化需要返回的字符串
        var returnMessage:String = ""
        //通过file获取文件的名称
        if let className = file.components(separatedBy: "/").last {
            //拼接字符串
            returnMessage = "\n" +
                "className:\(className)\n" +
                " function:\(function)\n" +
                "      ine:\(line)\n" +
            "  message:\(message)"
        }else {
            //拼接字符串
            returnMessage = "\n" +
                " function:\(function)\n" +
                "      ine:\(line)\n" +
            "  message:\(message)"
        }
        return returnMessage
    }

}

/**
 输出Info等级的日志消息
 */
func LogInfo(message: String, file: String = #file, function: String = #function, line: UInt = #line) {
    DDLogInfo(XBLog.getMessage(message, file: file, function: function, line: line))
}

/**
 输出Error等级的日志消息
 */
func LogError(message: String, file: String = #file, function: String = #function, line: UInt = #line) {
    DDLogError(XBLog.getMessage(message, file: file, function: function, line: line))
}

/**
 输出Debug等级的日志消息
 */
func LogDebug(message: String, file: String = #file, function: String = #function, line: UInt = #line) {
    DDLogDebug(XBLog.getMessage(message, file: file, function: function, line: line))
}

/**
 输出Warn等级的日志消息
 */
func LogWarn(message: String, file: String = #file, function: String = #function, line: UInt = #line) {
    DDLogWarn(XBLog.getMessage(message, file: file, function: function, line: line))
}
