//
//  XBAlertController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/26.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBAlertController: UIViewController, UIGestureRecognizerDelegate {
    
    private var alertTitle: String?
    private var alertMessage:String?
    
    private var alertView:XBAlertView?
    
    var clickAction:((Int)->())?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    convenience init(title:String?, message:String?) {
        self.init()
        
        self.alertTitle = title
        self.alertMessage = message
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        setup()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        alertView?.width = view.width - 42 * UIRate
        alertView?.centerX = view.centerX
        alertView?.centerY = view.centerY
        alertView?.clickBtnBlock = { [weak self] tag in
            if self?.clickAction != nil {
                self?.close()
                self?.clickAction!(tag)
            }
        }
    }
    
    //MARK: - Setup
    
    private func setup() {
        alertView = XBAlertView(title: alertTitle, message: alertMessage)
        view.addSubview(alertView!)
    }
    
    //MARK: - Gesture
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.view
    }
    

}

extension XBAlertController: UIViewControllerTransitioningDelegate {
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController)
        -> UIPresentationController? {
            return XBDimmingPresentationController( presentedViewController: presented,
                                                    presenting: presenting)
    }

}


