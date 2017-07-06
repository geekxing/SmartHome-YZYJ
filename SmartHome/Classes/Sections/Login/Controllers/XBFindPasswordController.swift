//
//  XBFindPasswordController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2016/12/6.
//  Copyright © 2016年 helloworld.com. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class XBFindPasswordController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var smallBackground: UIView!
    
    var email:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if self.isMember(of: XBFindPasswordController.self) {
            emailField.text = email
        }
        backButton.layer.cornerRadius = backButton.height * 0.5
        submitButton.layer.cornerRadius = submitButton.height * 0.5
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleLabel.sizeToFit()
        titleLabel.centerX = view.width * 0.5
    }
    
    //MARK: - Action
    @IBAction func textDidTapReturnKey(_ sender: UITextField) {
        submit(submitButton)
    }

    @IBAction func submit(_ sender: UIButton) {
        email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (emailField.isBlank()) {
            self.view.makeToast(NSLocalizedString("Please enter full information", comment: ""))
            return
        }
        let params = ["email":email!]
        emailField.resignFirstResponder()
        
        SVProgressHUD.show()
        XBNetworking.share.postWithPath(path: FORGET, paras: params,
                                        success: {[weak self] (json, message) in
                                            if json[Code].intValue == normalSuccess {
                                                let verify = XBVerifyCodeViewController(nibName: "XBFindPasswordController", bundle: nil)
                                                verify.email = self?.email
                                                self!.navigationController?.pushViewController(verify, animated: true)
                                            } else {
                                                SVProgressHUD.showError(withStatus: message)
                                            }
            }, failure: { error in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
        })
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController!.popViewController(animated: true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
