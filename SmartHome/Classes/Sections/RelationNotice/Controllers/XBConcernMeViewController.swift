//
//  XBConcernMeViewController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/20.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift
import SVProgressHUD
import MJRefresh

class XBConcernMeViewController: UIViewController {
    
    static let reuseHeaderId = "reuseHeaderId"
    let token = XBLoginManager.shared.currentLoginData!.token
    
    var loginUser: XBUser? {
        return XBUserManager.shared.loginUser()
    }
    var tableView:UITableView!
    private var shawdowLine:UIImageView!
    
    var tableGroups:[XBTableGroupItem] = [XBTableGroupItem(),XBTableGroupItem()]
    var applyGroup:[XBRelationConcernModel] = []
    var concernMe:[XBRelationConcernModel] = []
    
    lazy var mjheader:MJRefreshNormalHeader = {
         let mjH = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.loadData()
        }) as MJRefreshNormalHeader
        mjH.isAutomaticallyChangeAlpha = true
        return mjH
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupShadow()
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: 0, y: 32, width: view.width, height: view.height-32)
    }
    
    //MARK: - Setup
    
    private func setupShadow() {
        shawdowLine = UIImageView(image: UIImage(named: "horizontalShadow"))
        shawdowLine.width = view.width
        shawdowLine.height = 8;
        shawdowLine.left = 0;
        shawdowLine.top  = 32;
        view.addSubview(shawdowLine)
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionFooterHeight = 0
        tableView.sectionHeaderHeight = 20
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 71.0
        registerCell()
        tableView.register(XBTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: XBConcernMeViewController.reuseHeaderId)
        tableView.mj_header = self.mjheader
        view.addSubview(tableView)
    }
    
    func registerCell() {
        tableView.register(XBApplyConcernCell.self, forCellReuseIdentifier: ApplyConcern)
        tableView.register(XBConcernMeCell.self, forCellReuseIdentifier: ConcernMe)
    }
    
    
    //MARK: - Data
    func loadData() {
        if self.parent!.isKind(of: XBRelationNoticeController.self) {
            let parentVc = self.parent as! XBRelationNoticeController
            
            let globalQueue = DispatchQueue.global()
            let group = DispatchGroup()
            let semaphore = DispatchSemaphore(value: 0)
            
            let workItem1 = DispatchWorkItem(qos: .userInitiated, flags: .assignCurrentContext) {
                parentVc.getConcern(GET_WAIT ,complete: {[weak self] (data, _) in
                    if let json = data {
                        if json[Code] == 1 {
                            self?.makeData(data: json, ApplyConcern)
                        }
                    }
                    semaphore.signal()
                })
            }
            globalQueue.async(group: group, execute: workItem1)
            
            let workItem2 = DispatchWorkItem(qos: .userInitiated, flags: .assignCurrentContext) {
                parentVc.getConcern(GET_CONCERNME ,complete: {[weak self] (data, _) in
                    if let json = data {
                        if json[Code] == 1 {
                            self?.makeData(data: json, ConcernMe)
                        }
                    }
                    semaphore.signal()
                })
            }
            globalQueue.async(group: group, execute: workItem2)
            
            group.notify(queue: globalQueue, execute: {
                
                let delay = DispatchTime.distantFuture
                var st = 0
                for _ in 0..<2 {
                    switch semaphore.wait(timeout: delay) {
                    case .success: st += 1
                    default:break
                    }
                }
                if st == 2 {
                    DispatchQueue.main.async(execute: {
                        self.tableView.mj_header.endRefreshing()
                        self.tableView.reloadData()
                    })
                }
                
            })
            
        }
    }
    
    func makeData(data:JSON , _ tag:String) {
        let array = data[XBData].arrayValue
        var dataArray = [XBRelationConcernModel]()
        for userData in array {
            let user = XBUserManager.shared.user(userData)
            let model = XBRelationConcernModel()
            model.user = user
            model.tag = tag
            dataArray.append(model)
        }

        let group = XBTableGroupItem()
        group.items = dataArray
        group.headerTitle = tag
        let index = tag == ApplyConcern ? 0 : 1
        self.tableGroups[index] = group
    }
    
    //MARK: - Private
    private func clear() {
        tableGroups.removeAll()
        applyGroup.removeAll()
        concernMe.removeAll()
    }

    //MARK: - Operations
    
    func reload() {
        self.tableView.reloadData()
    }
    
    ///处理关注我
    fileprivate func handleNotice(_ otherEmail:String,  handle:String) {
        let params:Dictionary = ["token":token,
                                 "email":otherEmail,
                                 "handle":handle]
        SVProgressHUD.show()
        XBNetworking.share.postWithPath(path: HANDLE, paras: params, success: { [weak self] (json, message) in
            if json[Code].intValue == normalSuccess {
                self?.loadData()
            } else {
                SVProgressHUD.showError(withStatus: message)
            }
        }) { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    ///删除关注我的人
    
    func cancelAlert(_ otherEmail:String, otherName:String?, type:String) {
        let otherNameStr = otherName != nil ? otherName! : otherEmail
        let title = type == "myConcern" ? String(format: NSLocalizedString("CANCEL_CARE_OTHER_TIP", comment: "") , otherNameStr) : String(format: NSLocalizedString("CANCEL_CARED_BY_OTHER_TIP", comment: "") , otherNameStr)
        let vc = XBAlertController(title:title ,message: "")
        vc.clickAction = { [weak self] index in
            switch index {
            case 0: self?.cancelConcern(otherEmail, type: type)
            default: break
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    fileprivate func cancelConcern(_ otherEmail:String, type:String) {
        let params:Dictionary = ["token":token,
                                 "email":otherEmail,
                                 "type":type ]
        XBNetworking.share.postWithPath(path: CANCEL, paras: params, success: {[weak self] (json, message) in
            if json[Code].intValue == normalSuccess {
                self?.loadData()
            } else {
                SVProgressHUD.showError(withStatus: message)
            }
        }) { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    
}

extension XBConcernMeViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let group = tableGroups[section]
        return group.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model:XBRelationConcernModel!
        let group = tableGroups[indexPath.section]
        model = group.items[indexPath.row] as? XBRelationConcernModel
        
        var cell:XBRelationConcernCell! = XBRelationConcernCell()
        switch model.tag {
        case ApplyConcern:
            let applyCell = tableView.dequeueReusableCell(withIdentifier: ApplyConcern) as! XBApplyConcernCell
            applyCell.clickAgreeButton = {[weak self] user in
                self?.handleNotice(user.email!, handle: "agree")
            }
            applyCell.clickRefuseButton = {[weak self] user in
                self?.handleNotice(user.email!, handle: "disagree")
            }
            cell = applyCell
            
        case ConcernMe:
            let concernMeCell = tableView.dequeueReusableCell(withIdentifier: ConcernMe) as! XBConcernMeCell
            concernMeCell.clickCancelButton = {[weak self] user in
                self?.cancelAlert(user.email!, otherName: user.name, type: "concernMe")
            }
            cell = concernMeCell
        default:break
        }
        cell.model = model

        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 71.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let group = tableGroups[section]
        if group.items.count == 0 {return nil}
        return tableGroups[section].headerTitle
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerSectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: XBConcernMeViewController.reuseHeaderId)
        headerSectionView?.textLabel?.text = tableGroups[section].headerTitle
        return headerSectionView
    }
    
}
