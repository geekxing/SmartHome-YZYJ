//
//  XBFileLocationHelper.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2016/11/30.
//  Copyright © 2016年 helloworld.com. All rights reserved.
//

import UIKit

class XBFileLocationHelper: NSObject {
    
    class func getAppDocumentPath() -> String {
        let appDocumentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        print(appDocumentPath)
        if !FileManager.default.fileExists(atPath: appDocumentPath) {
            do {
                try FileManager.default.createDirectory(atPath: appDocumentPath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("文件夹创建失败")
            }
        }
        return appDocumentPath
    }
    
    class func appTempPath() -> String {
        return NSTemporaryDirectory()
    }
    
    class func userDirectory() -> String {
        let documentPath = XBFileLocationHelper.getAppDocumentPath()
        let userID = XBUserManager.shared.currentAccount()! as NSString
        guard userID.length != 0 else {
            print("Error: Get User Directory While UserID Is Empty");return documentPath
        }
        let userDirectory = "\(documentPath)\(userID))"
        if !FileManager.default.fileExists(atPath: userDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: userDirectory, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("文件夹创建失败")
            }
        }
        return userDirectory
    }
    
}
