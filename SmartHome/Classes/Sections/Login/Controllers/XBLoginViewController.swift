//
//  XBLoginViewController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2016/11/23.
//  Copyright © 2016年 helloworld.com. All rights reserved.
//

import UIKit
import SwiftyJSON
import IQKeyboardManagerSwift
import SVProgressHUD
import RealmSwift

class XBLoginViewController: UIViewController, UITextFieldDelegate, XBRegisterViewControllerDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var findPasswordBtn: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    var registerData = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        if let loginData = XBLoginManager.shared.currentLoginData {
            usernameTextField.text = loginData.account
            passwordTextField.text = loginData.password
            //token值不为空，则尝试自动登录
            if (loginData.token as NSString).length != 0 {
                canAutoLogin(loginData.token)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.registerData {
            self.registerData = false
            return
        }
        if let loginData = XBLoginManager.shared.currentLoginData {
            usernameTextField.text = loginData.account
            passwordTextField.text = loginData.password
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" && textField.returnKeyType == .done {
            doLogin()
            return false
        }
        return true
    }
    
    @objc private func textFieldDidChange(notification:NSNotification) {
        onTextChanged()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        onTextChanged()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            IQKeyboardManager.sharedManager().goNext()
        } else {
            doLogin()
        }
        return true
    }
    
    //MARK: - 自动登录
    func canAutoLogin(_ token:String) {
        
        SVProgressHUD.show()
        let params = ["token":token]
        XBNetworking.share.postWithPath(path: CHECK_TOKEN, paras: params,
                                        success: {[weak self] (json, message) in
                                            if json[Code].intValue == 1 {
                                                XBUserManager.shared.fetchUserFromServer(token: token, handler: { (user, error) in
                                                    if error == nil {
                                                        Bugly.setUserIdentifier(user!.email)
                                                        self!.navigationController!.pushViewController(XBMainViewController(), animated: true)
                                                    }
                                                })
                                            } else {
                                                SVProgressHUD.showError(withStatus: message)
                                            }
            }, failure: { (error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
        })
    }
    
    //MARK: - Action
    func doLogin() {
        view.endEditing(true)
        
        let username = usernameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let password = passwordTextField.text
        
        if let uid = username, let pwd = password {
            if (uid as NSString).length == 0 || (pwd as NSString).length == 0 {
                self.view.makeToast(NSLocalizedString("Please enter full information", comment: ""))
            } else {
                
                XBOperateUtils.shared.login(email: uid, pwd: pwd, success: { [weak self] (result) in
                    self!.navigationController!.pushViewController(XBMainViewController(), animated: true)
                }) { (error) in
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func onTouchLogin(_ sender: UIButton) {
        doLogin()
    }
    
    @IBAction func onTouchRegister(_ sender: UIButton) {
        let registerVC = XBRegisterViewController()
        registerVC.delegate = self
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func onTouchFindPwd(_ sender: UIButton) {
        let findPwdVC = XBFindPasswordController()
        findPwdVC.email = usernameTextField.text
        navigationController?.pushViewController(findPwdVC, animated: true)
    }
    
    //MARK: - XBRegisterViewControllerDelegate
    func regisDidComplete(account: String?, password pwd: String?) {
        registerData = true
        usernameTextField.text = account
        passwordTextField.text = pwd
    }
    
    //MARK: - Private
    private func setAllTextFieldReturnType(type:UIReturnKeyType) {
        for subview in view.subviews {
            if subview.isKind(of: UITextField.self) {
                let textField = subview as! UITextField
                textField.returnKeyType = type
            }
        }
    }
    
    private func onTextChanged() {
        if usernameTextField.isBlank() || passwordTextField.isBlank() {
            setAllTextFieldReturnType(type: .next)
        } else {
            setAllTextFieldReturnType(type: .done)
        }
    }
}
