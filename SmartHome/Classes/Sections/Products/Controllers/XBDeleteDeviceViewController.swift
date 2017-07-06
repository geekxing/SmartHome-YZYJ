//
//  XBDeleteDeviceViewController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/20.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class XBDeleteDeviceViewController: UIViewController {
    
    @IBOutlet weak var snField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    let token = XBLoginManager.shared.currentLoginData!.token
    var loginUser:XBUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        snField.text = loginUser?.Device().first
        backButton.layer.cornerRadius = backButton.height * 0.5
        submitButton.layer.cornerRadius = submitButton.height * 0.5
    }
    
    //MARK: - Action
    
    @IBAction func textDidTapReturnKey(_ sender: UITextField) {
        submit(submitButton)
    }
    
    @IBAction func submit(_ sender: UIButton) {
        if (snField.text! as NSString).length == 0 {
            UIAlertView(title: NSLocalizedString("SN is empty", comment: ""), message: nil, delegate: nil, cancelButtonTitle: NSLocalizedString("DONE", comment: "")).show()
        } else {
            deleteDeviceAlert()
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController!.popViewController(animated: true)
    }
    
    //MARK: - Private
    
    private func deleteDeviceAlert() {
        let vc = XBAlertController(title: NSLocalizedString("Are you sure to delete the device?", comment: ""), message: "")
        vc.clickAction = { [weak self] index in
            switch index {
            case 0: self?.deletDevice(sn: self?.snField.text ?? "")
            default: break
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    private func deletDevice(sn:String) {
        
        let params:Dictionary = ["token":token,
                                 "sn":sn]
        
        SVProgressHUD.show()
        XBNetworking.share.postWithPath(path: DEVICE_DELETE, paras: params,
                                        success: { [weak self] (json, message) in
                                            if json[Code].intValue == normalSuccess {
                                                self!.checkUserInfo()
                                            } else {
                                                SVProgressHUD.showError(withStatus: message)
                                            }
            }, failure: { (error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
        })
        
    }
    
    private func checkUserInfo() {
        
        XBUserManager.shared.fetchUserFromServer(token: token) { (_, error) in
            if error == nil {
                self.navigationController!.popViewController(animated: true)
            }
        }
        
    }

}
