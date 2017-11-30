//
//  XBClockKnockViewController.swift
//  SmartHome
//
//  Created by apple on 2017/11/30.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//  设定闹铃-本地提醒

import UIKit

class XBClockKnockViewController: XBBaseViewController {
    
    var clockView:XBClockKnockView!
    
    override var naviTitle: String? {
        return NSLocalizedString("Clock", comment: "")
    }
    
    override var naviBackgroundImage: UIImage? {
        return UIImage(named: "RectHeader")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let naviHeight = (naviBackgroundImage!.size.height)
        self.clockView = XBClockKnockView(frame: CGRect(x: 0, y: naviHeight, width: view.width, height: view.height-naviHeight))
        self.view.addSubview(self.clockView)
        
        let acc = XBLoginManager.shared.currentLoginData!.account + "clock"
        let data = (UserDefaults.standard.value(forKey: acc) ?? []) as! [Dictionary<String, String>]
        self.clockView.setDatasource(data)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

}
