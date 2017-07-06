//
//  XBModifyPasswordViewController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/4/1.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class XBModifyPasswordViewController: XBFindPasswordController, UITextFieldDelegate {
    
    let confirmPasswordField = XBRoundedTextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = NSLocalizedString("Reset Password", comment: "")
        tipLabel.removeFromSuperview()
        headLabel.removeFromSuperview()
        
        //此处emailField用作密码输入框
        emailField.placeholder = NSLocalizedString("New Password", comment: "")
        emailField.isSecureTextEntry = true
        emailField.delegate = self
        
        confirmPasswordField.font = UIFontSize(14)
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.placeholder = NSLocalizedString("Confirm Password", comment: "")
        confirmPasswordField.returnKeyType = .done
        confirmPasswordField.delegate = self
        
        smallBackground.addSubview(confirmPasswordField)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        emailField.top = 60
        
        confirmPasswordField.width = 306*UIRate
        confirmPasswordField.height = 29
        confirmPasswordField.centerX = view.centerX
        confirmPasswordField.top = emailField.bottom + 30
    }
    
    @IBAction override func submit(_ sender: UIButton) {
        if (email == nil || emailField.isBlank() || confirmPasswordField.isBlank()) {
            self.view.makeToast(NSLocalizedString("Please enter full information", comment: ""))
            return
        }
        if !XBOperateUtils.validatePassword(emailField.text!, confirmPwd: confirmPasswordField.text!) {
            return
        }
        let params = ["email":email!,
                      "password":emailField.text!]
        emailField.resignFirstResponder()
        
        SVProgressHUD.show()
        XBNetworking.share.postWithPath(path: MODIFY_PWD, paras: params,
                                        success: { [weak self] (json, message) in
                                            if json[Code].intValue == normalSuccess {
                                                self!.navigationController!.popToRootViewController(animated: true)
                                            } else {
                                                SVProgressHUD.showError(withStatus: message)
                                            }
            }, failure: { error in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
        })
    }

}
