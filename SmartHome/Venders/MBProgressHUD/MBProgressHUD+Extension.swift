//
//  MBProgressHUD+Extension.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2016/11/24.
//  Copyright © 2016年 helloworld.com. All rights reserved.
//
import Foundation

extension MBProgressHUD {
    //MARK: Class methods
    
    static func defaultShow(text:String?) -> MBProgressHUD {
        let hud = self.showAdded(to: getCurrentVC().view, animated: true)
        hud.bezelView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        hud.label.text = text
        hud.label.textColor = UIColor.white
        return hud
    }
    
    static func showText(text:String?) -> MBProgressHUD {
        let hud = self.defaultShow(text: text)
        hud.mode = .text
        return hud
    }
    
    private static func getCurrentVC() -> UIViewController {
        var vc:UIViewController? = nil
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindowLevelNormal {
            let windows = UIApplication.shared.windows
            for win in windows {
                if win.windowLevel == UIWindowLevelNormal {
                    window = win;break
                }
            }
        }
        let frontView = window?.subviews[0]
        if let nextResponder = frontView?.next {
            if nextResponder.isKind(of: UIViewController.self) {
                vc = nextResponder as? UIViewController
            } else {
                vc = window?.rootViewController
            }
        }
        return vc!
    }
}
