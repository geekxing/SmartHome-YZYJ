//
//  XBBaseViewController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/25.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBBaseViewController: UIViewController {
    
    let token = XBLoginManager.shared.currentLoginData!.token
    
    var naviBackgroundImage:UIImage? {
        return nil
    }
    var naviTitle:String? {
        return nil
    }
    
    var loginUser:XBUser? {
        if let user = XBUserManager.shared.loginUser() {
            return user
        }
        return nil
    }
    
    deinit {
        XBNetworking.share.cancel()
        print("deinit")
    }
    
    private var naviBackground:UIImageView!
    private var titleLabel:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        NotificationCenter.default.addObserver(self, selector: #selector(onStatusFrameChanged(_:)), name:Notification.Name.UIApplicationWillChangeStatusBarFrame , object: nil)
    }
    
    private func setupNavigation() {
        naviBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: view.width, height:naviBackgroundImage!.size.height*UIRate))
        naviBackground.image = naviBackgroundImage
        titleLabel = UILabel()
        titleLabel.text = naviTitle
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = UIFontSize(27*UIRate)
        titleLabel.sizeToFit()
        titleLabel.centerX = naviBackground.centerX
        titleLabel.top = UIRate * 24
        naviBackground.addSubview(titleLabel)
        view.addSubview(naviBackground)
    }
    
    //MARK: - Notification
    func onStatusFrameChanged(_ aNote:Notification) {
        
    }

}
