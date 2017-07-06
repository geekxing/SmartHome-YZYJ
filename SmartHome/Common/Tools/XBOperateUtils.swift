//
//  XBOperateUtils.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/1/15.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import SVProgressHUD

class XBOperateUtils: NSObject {
    
    private var loginUser:XBUser! {
        if let user = XBUserManager.shared.loginUser() {
            return user
        }
        return nil
    }

    static let shared = XBOperateUtils()
    
    func login(email:String, pwd:String, success:@escaping (_ result:Any)->(), failure:@escaping (_ error:Error)->()) {
        
        if !XBOperateUtils.validateEmail(email) {
            SVProgressHUD.showError(withStatus: NSLocalizedString("Email format error", comment: ""))
            return
        }
        let params = [
            "email":email,
            "password":pwd
        ]
        
        SVProgressHUD.show()
        XBNetworking.share.postWithPath(path: LOGIN, paras: params,
                                        success: { (json, message) in
                                            let tk = json[XBData]["token"].stringValue
                                            if json[Code].intValue == 1 {  //登录成功
                                                //登录信息本地缓存
                                                let loginData = LoginData(account: email, password:pwd, token: tk)
                                                Bugly.setUserIdentifier(email)
                                                XBLoginManager.shared.currentLoginData = loginData
                                                //用户信息本地缓存
                                                XBUserManager.shared.addUser(userJson: json[XBData]["userInfo"])
                                                success(message)
                                            } else {   //服务器返回失败原因
                                                failure(NSError(domain: SMErrorDomain, code: json[Code].intValue, userInfo: [kCFErrorLocalizedDescriptionKey as AnyHashable :message]))
                                            }
        }, failure: { error in
            failure(error)
        })
    }
    
    class func timeComps(_ timeGap:Double) -> (hour:Int, minute:Int) {
        let h = Int(timeGap / 3600)
        let leftGap = timeGap - Double(h * 3600)
        let m = Int(leftGap / 60)
        return (h, m)
    }
    
    //MARK: - 获取某年某月的天数
    func howManyDaysInThisYear(_ year:Int, _ month:Int) -> Int{
        if (month == 1) || (month == 3) || (month == 5) || (month == 7) || (month == 8) || (month == 10) || (month == 12) {
            return 31 ;
        }
    
        if (month == 4) || (month == 6) || (month == 9) || (month == 11) {
            return 30;
        }
    
        if(year % 4 == 1) || (year % 4 == 2) || (year % 4 == 3)
        {
            return 28;
        }
    
        if(year % 400 == 0) {
            return 29;
        }
    
        if(year % 100 == 0) {
            return 28;
        }
        
        return 29;
    }
    
    class func validateEmail(_ email: String) -> Bool {
        let emailString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailString)
        return emailPredicate.evaluate(with: email)
    }
    
    class func validatePassword(_ pwd:String, confirmPwd:String) -> Bool {
        
        let pwdRegex = "^[0-9a-zA-Z]{6,16}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pwdRegex)
        let isPwd = predicate.evaluate(with: pwd)
        
        if !isPwd {
            SVProgressHUD.showError(withStatus:
                NSLocalizedString("Password can only be the combination of numbers and letters. It may not be less than 6 or more than 16 characters", comment: ""))
            return false
        }
        if pwd != confirmPwd {
            SVProgressHUD.showError(withStatus: NSLocalizedString("Two passwords are not the same!", comment: ""))
            return false
        }
        return true
        
    }
    
    //MARK: - Private
    private func setDefaultRealmForUser(username: String) {
        var config = Realm.Configuration()
        
        // 使用默认的目录，但是使用用户名来替换默认的文件名
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("\(username).realm")
        
        // 将这个配置应用到默认的 Realm 数据库当中
        Realm.Configuration.defaultConfiguration = config
    }
}
