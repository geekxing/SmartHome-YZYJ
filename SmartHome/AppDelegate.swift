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

var datePicker:UIDatePicker? = {
    let dPicker = UIDatePicker()
    dPicker.datePickerMode = .date;
    dPicker.maximumDate = Date()
    dPicker.frame = CGRect(x: 0.0, y: 0.0, width: dPicker.width, height: 250.0)
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
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        DropDown.startListeningToKeyboard()
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMaximumDismissTimeInterval(3.0)
        SVProgressHUD.setMinimumDismissTimeInterval(3.0)
        SVProgressHUD.setDefaultAnimationType(.native)
        
        XBLog.configDDLog()
        
        Bugly.start(withAppId: "86e9c0d8d0")
        
        setupMainViewController()
        commenInitListenEvents()
        realmMigration()
        
        return true
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
    
}

