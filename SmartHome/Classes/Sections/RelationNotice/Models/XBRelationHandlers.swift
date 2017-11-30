//
//  XBRelationHandlers.swift
//  SmartHome
//
//  Created by apple on 2017/11/30.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import SVProgressHUD

class XBRelationHandlers: NSObject {
    
    static func apply(email:String) {
        let params:Dictionary = ["token":XBLoginManager.shared.currentLoginData!.token,
                                 "email":email]
        XBNetworking.share.postWithPath(path: APPLY, paras: params, success: { (json, message) in
            if json[Code].intValue == normalSuccess {
            } else {
                SVProgressHUD.showError(withStatus: message)
            }
        }) { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    
}
