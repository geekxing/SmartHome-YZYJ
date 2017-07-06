//
//  XBVerifyCodeViewController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/4/1.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class XBVerifyCodeViewController: XBFindPasswordController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = NSLocalizedString("Verify Code", comment: "")
        tipLabel.text = NSLocalizedString("Please enter the verification code", comment: "")
        headLabel.text = NSLocalizedString("Verify Code", comment: "")
        headLabel.sizeToFit()
        ///因为继承方便，此处的emailField 用作验证码的textField
        emailField.placeholder = NSLocalizedString("Enter Verify Code", comment: "")
        
    }
    
    @IBAction override func submit(_ sender: UIButton) {
        if (email == nil || emailField.isBlank()) {
            self.view.makeToast(NSLocalizedString("Please enter full information", comment: ""))
            return
        }
        let params = ["email":email!,
                      "verifi":emailField.text!]
        emailField.resignFirstResponder()
        
        SVProgressHUD.show()
        XBNetworking.share.postWithPath(path: VERIFY_CODE, paras: params,
                                        success: { [weak self] (json, message) in
                                            if json[Code].intValue == normalSuccess {
                                                let modifyPwd = XBModifyPasswordViewController(nibName: "XBFindPasswordController", bundle: nil)
                                                modifyPwd.email = self?.email
                                                self!.navigationController?.pushViewController(modifyPwd, animated: true)
                                            } else {
                                                SVProgressHUD.showError(withStatus: message)
                                            }
            }, failure: { error in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
        })
    }
    

}
