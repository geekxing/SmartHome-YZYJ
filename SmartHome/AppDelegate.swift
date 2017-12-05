//
//  AppDelegate.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2016/11/22.
//  Copyright © 2016年 helloworld.com. All rights reserved.
//

import UIKit
import SVProgressHUD
import IQKeyboardManagerSwift
import DropDown
import RealmSwift
import UserNotifications

var datePicker:UIDatePicker? = {
    let dPicker = UIDatePicker()
    dPicker.datePickerMode = .date;
    dPicker.maximumDate = Date()
    dPicker.frame = CGRect(x: 0.0, y: 0.0, width: dPicker.width, height: 216.0)
    return dPicker
}()

let SMErrorDomain  = "com.sm.app"
let XBImagePrefix  = "http://118.178.181.188:8080/"
let XBNotificationLogout = "XBNotificationLogout"
let baseRequestUrl = "http://118.178.181.188:8080/SleepMonitor/"
let Code = "Code"
let Message = "Message"
let XBData = "Data"

//成功码
let normalSuccess = 1
let updateInfo    = 1006
let tokenSend     = 1007
let findUser      = 1011
let applyNotice   = 1013
let applyPass     = 1015
let cancelNotice  = 1017
let bindDevice    = 1024
let deleteDevice  = 1026

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        configThirdParties()
        setupMainViewController()
        commenInitListenEvents()
        realmMigration()
        registerNotifications()
        
        if let launchOpt = launchOptions {
            if launchOpt[UIApplicationLaunchOptionsKey.localNotification] != nil {
                //在APP被杀死的时候点击通知唤醒APP不会响应其他代理方法，故只能从这取通知
                var things = [Any]()
                things.append(launchOpt[UIApplicationLaunchOptionsKey.localNotification]!)
                for thing in things {
                    switch thing {
                    case let localNote as UILocalNotification: ///UIConcreteLocalNotification
                        handleLocalNote(localNote.userInfo)
                    default:break
                    }
                }
            }
        }
        
        return true
    }
    
    //这个方法好像只有在用户在前台的时候才会走
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if (application.applicationState == .active) {
            handleLocalNote(notification.userInfo)
        } else {
            print(application.applicationState)
        }
    }
    
    func application(_ application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
        if let win = window {
            win.top = (newStatusBarFrame.height < 40) ? 0 : 20
            win.height = (newStatusBarFrame.height < 40) ? SCREEN_HEIGHT : SCREEN_HEIGHT - 20
            if newStatusBarFrame.height < 40 {
                for view in win.subviews {
                    view.frame = win.bounds
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - UNUserNotificationCenterDelegate
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("在前端收到通知%@", userInfo)
        handleLocalNote(userInfo)
        completionHandler([.alert, .badge, .sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("点击响应通知%@", userInfo)
        handleLocalNote(userInfo)
        completionHandler()
    }
    
    
    //MARK: - Methods
    func handleLocalNote(_ userInfo:[AnyHashable : Any]?) {
        let acc = XBLoginManager.shared.currentLoginData!.account + "clock"
        var data = (UserDefaults.standard.value(forKey: acc) ?? []) as! [Dictionary<String, String>]
        for (idx, dict) in data.enumerated() {
            if let info = userInfo, let identifier = info["id"] {
                if dict["id"] == (identifier as! String) {
                    //已经接收到的本地通知移除掉
                    data.remove(at: idx); break
                }
            }
        }
        UIApplication.shared.applicationIconBadgeNumber = data.count
        UserDefaults.standard.setValue(data, forKey: acc)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:XBLocalNotificationNotification), object: nil, userInfo: userInfo)
    }
    
    func setupMainViewController() {
        //暂时没有自动登录接口
        setupLoginVC()
    }
    
    func setupLoginVC() {
        let loginVC = XBLoginViewController()
        let nav = XBNavigationController(rootViewController: loginVC)
        window?.rootViewController = nav
    }
    
    func commenInitListenEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: NSNotification.Name(rawValue: XBNotificationLogout), object: nil)
    }
    
    @objc func logout(aNote:Notification) {
        setupLoginVC()
    }
    
    func configThirdParties() {
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
        DropDown.startListeningToKeyboard()
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMaximumDismissTimeInterval(3.0)
        SVProgressHUD.setMinimumDismissTimeInterval(3.0)
        SVProgressHUD.setDefaultAnimationType(.native)
        
        XBLog.configDDLog()
        
        Bugly.start(withAppId: "86e9c0d8d0")
    }
    
    func realmMigration() {
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
    }
    
    func registerNotifications() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { (granted, error) in
                if error == nil {
                    print("已经注册通知")
                }
            })
        } else {
            let settings = UIUserNotificationSettings(types: [.alert,.badge,.sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            print("已经注册通知")
        }
    }
    
}

