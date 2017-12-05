//
//  XBUserManager.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2016/12/5.
//  Copyright © 2016年 helloworld.com. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

let XBUserInfoHasChangedNotification = "XBUserInfoHasChangedNotification"

class XBUser: Object {
    @objc dynamic var id:String?
    @objc dynamic var userId:String?
    @objc dynamic var email:String!
    @objc dynamic var follower:Data? = Data()
    @objc dynamic var firstName = ""
    @objc dynamic var middleName:String?
    @objc dynamic var lastName = ""
    @objc dynamic var name:String?
    @objc dynamic var image:String? = ""
    @objc dynamic var password:String?
    @objc dynamic var mphone:String?
    @objc dynamic var address:String?
    @objc dynamic var gender:Int = 0
    @objc dynamic var birthDay:String?
    @objc dynamic var focus:Data? = Data()
    @objc dynamic var device:Data? = Data()
    @objc dynamic var createTime = 0.0
    
    @objc dynamic var type1sn:String?
    @objc dynamic var type1Ip:String?
    @objc dynamic var level1:String?
    @objc dynamic var deadline1:String?
    @objc dynamic var type2sn:String?
    @objc dynamic var type2Ip:String?
    @objc dynamic var level2:String?
    @objc dynamic var deadline2:String?
    @objc dynamic var type3sn:String?
    @objc dynamic var type3Ip:String?
    @objc dynamic var level3:String?
    @objc dynamic var deadline3:String?
    
    override static func primaryKey() -> String? {
        return "email"
    }
    
    func Name() -> String {
        let middleName = self.middleName ?? ""
        let name = firstName.isChinese() || lastName.isChinese() ? lastName+firstName : firstName + " " + middleName + " " + lastName
        return name
    }
    
    @objc func Device() -> [String] {
        if let data = self.device {
            return data.count == 0 ? [] : try! JSONSerialization.jsonObject(with: data, options: []) as! [String]
        }
        return []
    }
    
    //MARK: - Overrides
    
    override var debugDescription: String {
        
        var des = ""
        let properties = XBUser.properties_name()
        for property in properties {
            des += " \(property) : \(String(describing: self.value(forKey: property))) "
        }
        return des
       
    }
    
    override func setNilValueForKey(_ key: String) {
        if key == "follower" || key == "focus" || key == "device" {
            self.setValue(Data(), forKey: key)
        } else if key == "gender" || key == "createTime" {
            self.setValue(0, forKey: key)
        } else {
            super.setNilValueForKey(key)
        }
    }
    
}

class XBUserManager: NSObject {
    @objc static let shared = XBUserManager()
    
    let userProperties = XBUser.properties_name()
    
    //MARK: -
    ///
    /// 返回当前登录账号
    ///
    /// - Returns: 当前登录账号
    ///
    func currentAccount() -> String? {
        return XBLoginManager.shared.currentLoginData?.account
    }
    
    ///
    /// 返回当前登录用户信息
    ///
    /// - Returns: 当前登录用户信息
    ///
    @objc func loginUser() -> XBUser? {
        if let userID = XBUserManager.shared.currentAccount() {
            if let loginUser = XBUserManager.shared.user(uid: userID) {
                return loginUser
            }
        }
        return nil
    }
    
    
    func user(_ userJson:JSON) -> XBUser {
        
        let user = XBUser()
        for (key,subJson):(String, JSON) in userJson {
            if !self.userProperties.contains(key) {
                continue
            }
            var value:Any?
            if key == "birthDay" {
                if let dict = subJson.dictionaryObject {
                    if !dict.keys.contains("birthDay") {
                        let year = dict["year"] as! String
                        let month = dict["month"] as! String
                        let day  = dict["day"] as! String
                        value = "\(month)/\(day)/\(year)"
                    }
                }
            } else if subJson.type == .array {
                value = try! JSONSerialization.data(withJSONObject: subJson.rawValue, options: [])
            } else if subJson.type == .null {
            } else {
                value = subJson.stringValue
            }
            user.setValue(value, forKey: key)
        }
        return user
        
    }
    
    func addUser(userJson:JSON) {
        //用户信息本地缓存
        do {
            let realm = try Realm()
            print(realm.configuration.fileURL!)
            try! realm.write {
                let user = self.user(userJson)
                realm.add(user, update: true)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: XBUserInfoHasChangedNotification), object: user.email)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func add(user:XBUser) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(user, update: true)
        }
    }
    
    func placeholderForUser(uid:String) -> UIImage {
        return user(uid: uid)?.gender == 1 ? #imageLiteral(resourceName: "avatar_male") : #imageLiteral(resourceName: "avatar_female")
    }
    
    ///
    /// 返回单个用户信息
    ///
    /// - Parameter uid:用户id
    ///
    /// - Returns:当前登录账号
    func user(uid:String) -> XBUser? {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "email = [cd] %@", argumentArray: [uid])
        return realm.objects(XBUser.self).filter(predicate).first
    }
    
    ///
    /// 从服务器返回指定账号的用户信息
    ///
    /// - Returns:查询到的用户信息
    
    func fetchUserFromServer(token:String, handler: @escaping ((_ user:XBUser?, _ error: Error?) -> Void)) {
        
        let params = ["token":token]
        var usr:XBUser?
        XBNetworking.share.postWithPath(path: GET_INFO, paras: params,
                                        success: { (json, _) in
                                            if json[Code].intValue == 1 {
                                                let userData = json[XBData]
                                                let email = userData["email"].stringValue
                                                //用户信息本地缓存
                                                XBUserManager.shared.addUser(userJson: userData)
                                                usr = XBUserManager.shared.user(uid: email)
                                            }
                                            handler(usr, nil)
            }, failure: { (error) in
                handler(usr, error)
        })
        
    }
    
    
    //MARK: - Class Func
    class func integerForGender(_ gender:String) -> Int {
        return gender == NSLocalizedString("Male", comment: "") ? 1 : 0;
    }
    
    class func genderForInt(_ genderIndex:Int) -> String {
        return genderIndex == 0 ? NSLocalizedString("Female", comment: "") : NSLocalizedString("Male", comment: "")
    }
    
}
