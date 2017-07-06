//
//  XBMainViewController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2016/11/30.
//  Copyright © 2016年 helloworld.com. All rights reserved.
//

import UIKit
import Toast_Swift
import SVProgressHUD
import SwiftyJSON

class XBMainViewController: XBBaseViewController {
    
    override var naviBackgroundImage: UIImage? {
        return UIImage(named: "bigPublicHeader")
    }
    
    var mainView:XBMainView!
    var originBackButton:UIBarButtonItem?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        setupMainView()
        setupNaviItem()
        mainView.tapAvatar = { [weak self] (_) in
            self!.editUser()
        }
        view.addSubview(mainView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUserInfoUpdated(notification:)), name: NSNotification.Name(rawValue: XBUserInfoHasChangedNotification), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isMember(of: XBMainViewController.self) {
            //登录主页面后禁止侧滑手势，需要点击左上角“注销”按钮退出！
            (self.navigationController! as! XBNavigationController).shouldPopBlock = {}
        }
    }
    
    public func setupMainView() {
        mainView = XBMainView(frame: view.bounds)
        self.mainView.clickSquare = {[weak self] in
            switch $0.tag {
            case 0: self!.smartMattress()
            case 3: self!.relationConcern()
            case 4: self!.productVersion()
            default: break
            }
        }
    }
    
    func setupNaviItem() {
        self.originBackButton = self.navigationItem.leftBarButtonItem
        let backButton = UIButton(image: #imageLiteral(resourceName: "backButton"), backImage: nil, color: nil, target: self, sel:  #selector(back), title: NSLocalizedString("Log Out", comment: ""))
        backButton.setTitleColor(XB_DARK_TEXT, for: .normal)
        backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10)
        backButton.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named:"settings"), style: .plain, target: self, action: #selector(settings))
        
    }
    
    //MARK: - Notification
    @objc func onUserInfoUpdated(notification:Notification) {
        let uid = notification.object as! String
        let currentAccount = XBUserManager.shared.currentAccount()!
        guard currentAccount == uid else { return }
        mainView.currentUser = XBUserManager.shared.user(uid: uid)!
    }
    
    //MARK: - Private
    
    private func editUser() {
        
        let editUserVC = XBEditUserInfoViewController()
        editUserVC.loginUser = mainView.currentUser
        self.navigationController?.pushViewController(editUserVC, animated: true)
        
    }

    @objc private func settings() {
        editUser()
    }
    
    @objc private func back() {
        
        let params:Dictionary = ["token":token]
        
        SVProgressHUD.show()
        XBNetworking.share.postWithPath(path: LOGOUT, paras: params,
                                        success: { [weak self] (json, message) in
                                            if json[Code].intValue == 1 {
                                                let current = XBLoginManager.shared.currentLoginData
                                                current?.password = ""
                                                current?.token = ""
                                                XBLoginManager.shared.currentLoginData = current
                                                self!.navigationController!.popViewController(animated: true)
                                            } else {
                                                SVProgressHUD.showError(withStatus: message)
                                            }
            }, failure: { (error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
        })
    }
    
    private func smartMattress() {
        let vc = XBProductMainController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func relationConcern() {
        let vc = XBRelationNoticeController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func productVersion() {
        let vc = XBProductVersionController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
