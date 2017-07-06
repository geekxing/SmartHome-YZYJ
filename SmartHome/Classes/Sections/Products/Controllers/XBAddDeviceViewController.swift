//
//  XBAddDeviceViewController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/1/15.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class XBAddDeviceViewController: UIViewController {
    
    @IBOutlet weak var snField: UITextField!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    let token = XBLoginManager.shared.currentLoginData!.token
    private var typeSn:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setDefaultMaskType(.clear)
        
        snField.setValue(XB_DARK_TEXT, forKeyPath: "placeholderLabel.textColor")
        scanButton.titleEdgeInsets = UIEdgeInsetsMake(0, 19*UIRate, 0, 0)
        scanButton.contentEdgeInsets = UIEdgeInsetsMake(0, -100, 0, 0)
        scanButton.width = 200
        backButton.layer.cornerRadius = backButton.height * 0.5
        submitButton.layer.cornerRadius = submitButton.height * 0.5
    }
    
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        typeSn = oldText.replacingCharacters(in: range, with: string)
        let newText = typeSn! as NSString
        submitButton.isEnabled = newText.length != 0
        return true
    }
    
    //MARK: - Action
    
    @IBAction func beginScan(_ sender: UIButton) {
        
        if !XBPhotoPickerManager.shared.hasAccessTo(.camera) {
            return
        }
        XBPhotoPickerManager.shared.checkCameraAuth {[weak self] (flag) in
            if flag {
                let qrVC = XBQRCodeScanViewController()
                qrVC.returnScan = {[weak self] scan in
                    self?.snField.text = scan
                }
                self?.navigationController?.pushViewController(qrVC, animated: true)
            }
        }
        
    }

    @IBAction func textTapReturnKey(_ sender: UITextField) {
        submit(submitButton)
    }
    
    @IBAction func submit(_ sender: UIButton) {
        addDevice(sn: snField.text ?? "")
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController!.popViewController(animated: true)
    }

    //MARK: - Private
    private func addDevice(sn:String) {
        
        if (sn as NSString).length < 20 {
            UIAlertView(title: NSLocalizedString("Please enter at least 20 characters", comment: ""), message: nil, delegate: nil, cancelButtonTitle: NSLocalizedString("DONE", comment: "")).show()
            return
        }
        
        let params:Dictionary = ["token":token,
                                 "sn_all":sn]
        
        SVProgressHUD.show()
        XBNetworking.share.postWithPath(path: DEVICE_ADD, paras: params,
                                        success: {[weak self] (json, message) in
    
                                            let code = json[Code].intValue
                                            if code == normalSuccess || code == 1002 {
                                                self!.checkUserInfo(self!.token)
                                            } else {
                                                SVProgressHUD.showError(withStatus: message)
                                            }
            }, failure: { (error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
        })

    }
    
    private func checkUserInfo(_ token:String) {
        
        XBUserManager.shared.fetchUserFromServer(token: token, handler: { (user, error) in
            if error == nil {
                let bleVC = CBCentralViewController()
                self.navigationController!.pushViewController(bleVC, animated: true)
            }
        })
        
    }

}
