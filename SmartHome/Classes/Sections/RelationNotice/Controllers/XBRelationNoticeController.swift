//
//  XBRelationNoticeController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/1/15.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON
import Toast_Swift

class XBRelationNoticeController: XBBaseViewController {
    
    override var naviBackgroundImage: UIImage? {
        return UIImage(named: "RectHeader")
    }
    
    override var naviTitle: String? {
        return NSLocalizedString("FAMILY CARE", comment: "")
    }

    private var splitView:XBSplitView!
    fileprivate var realCurIndex = 0
    
    private var currentIndex:Int = -1;
    private var childViews:[UIView] = []
    
    private var applyConcernVC:XBApplyConcernViewController!
    private var concernMeVC:XBConcernMeViewController!
    private var myConcernMeVC:XBMyConcernViewController!
    private var scollView:UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        setupSplitView()
        setupScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        splitView.currentIndex = realCurIndex
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        realCurIndex = currentIndex
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    //MARK: - Public
    
    ///获取关注数据
    func getConcern(_ url:String , complete:@escaping ((_ data:JSON?, _ error:Error?)->())) {
        let params:Dictionary = ["token":token]
        
        XBNetworking.share.postWithPath(path: url, paras: params, success: { (json, message) in
            if json[Code] != 1 {
                SVProgressHUD.showError(withStatus: message)
            }
            complete(json, nil)
        }) { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            complete(nil, error)
        }
    }
    
    //MARK: - UI Setting
    
    private func setupSplitView() {
        splitView = XBSplitView(titles:
            [NSLocalizedString("Care\nRequest", comment: ""),
             NSLocalizedString("My\nCare", comment: ""),
             NSLocalizedString("Care\nMe", comment: "")])
        splitView.frame = CGRect(x: 0, y: (naviBackgroundImage!.size.height*UIRate), width: view.width, height: 82)
        splitView.cornerRadius = 5
        splitView.tapSplitButton = { [weak self] (index) in
            if self?.currentIndex != index {
                self?.currentIndex = index
            } else {
            }
            var offset = self!.scollView.contentOffset
            offset.x = CGFloat(index) * self!.scollView.width
            self!.scollView.setContentOffset(offset, animated: true)
        }
        view.addSubview(splitView)
    }
    
    private func setupScrollView() {
        
        scollView = UIScrollView(frame: CGRect(x:0, y:splitView.bottom-13, width:view.width, height:view.height-159))
        scollView.delegate = self
        scollView.backgroundColor = UIColor.white
        scollView.layer.cornerRadius = 5;
        view.addSubview(scollView)
        
        setupChildViewControllers()
        
        self.childViews = []
        for i in 0..<self.childViewControllers.count {
            let childView = self.childViewControllers[i].view
            self.childViews.append(childView!)
        }
        
        addChildViews()
        
    }
    
    private func setupChildViewControllers() {
        applyConcernVC = XBApplyConcernViewController()
        myConcernMeVC = XBMyConcernViewController()
        concernMeVC = XBConcernMeViewController()
        
        self.addChildViewController(applyConcernVC)
        self.addChildViewController(myConcernMeVC)
        self.addChildViewController(concernMeVC)
    }
    
    fileprivate func addChildViews() {
        
        let index = Int(scollView.contentOffset.x) / Int(scollView.width)
        let childView = childViews[index]
        if childView.window == nil {
            childView.frame = scollView.bounds
            scollView.addSubview(childView)
        }
    }
    
}

extension XBRelationNoticeController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    //UIScrollViewDelegate
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.addChildViews()
    }
    
}
