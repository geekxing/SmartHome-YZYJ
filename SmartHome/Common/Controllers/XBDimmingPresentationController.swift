//
//  XBDimmingPresentationController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/26.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBDimmingPresentationController: UIPresentationController {
    
    lazy var dimmingView:UIView! = {
        let dimming = UIView(frame: self.containerView!.bounds)
        dimming.backgroundColor =  UIColor(white: 1, alpha: 0.6)
        return dimming
    }()
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        self.dimmingView?.alpha = 0
        self.containerView?.insertSubview(dimmingView, at: 0)
        let transition = self.presentedViewController.transitionCoordinator
        transition?.animate(alongsideTransition: { [weak self] (context) in
            self?.dimmingView.alpha = 1
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { [weak self] (context) in
            self?.dimmingView.alpha = 0
            }, completion: nil)
    }

}
