//
//  XBSingleSelectHealthHistoryController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/25.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class XBSingleSelectHealthHistoryController: UIViewController {
    
    let token = XBLoginManager.shared.currentLoginData!.token
    let cellSelectedColor = UIColor(white: 0.82, alpha: 1)
    var needSort:Bool {
        return true
    }
    
    fileprivate let reuseIdentifier = "sleepCellID"
    
    var headerView:XBHealthCareHeaderView!
    var nowTapIndex     = 0
    var tableView:UITableView!
    var group:[XBSleepData] = []
    var selItemIdxSet = IndexSet(integer: 0)
    
    var other:XBUser?
    var type:XBCheckReportType = .me
    var url:String {
        return type == .me ? DEVICE_INFO : DEVICE_OTHERINFO
    }
    var params:[String:String] {
        
        let time = headerView.endDate.string(format: .custom("MM/dd/yyyy"))
        var params:Dictionary = ["token":token,
                                 "time":time]
        if type == .other {
            params["email"] = other!.email
        }
        return params
        
    }
    
    lazy var image:UIImage? = {
        return UIImage(named: "RectHeader")
    }()
    
    convenience init(_ user:XBUser?, type:XBCheckReportType) {
        self.init()
        self.other = user
        self.type = type
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        listenNotification()
        setupHeader()
        setupTableView()
        view.addSubview(headerView)
        makeData()
    }
    
    //MARK: - Setup
    func setupHeader() {
        headerView = XBHealthCareHeaderView(.single)
        headerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 121)
    }
    
    private func setupTableView() {
        //高度等于view高-分页器高-选择器高-查询器高
        tableView = UITableView(frame: CGRect(x: 0, y: headerView.bottom, width: view.width, height: view.height-94*UIRate-XBHealthCareViewController.splitViewH-headerView.height-image!.size.height*UIRate))
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        tableView.register(XBSleepHistoryTableCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
    }
    
    private func listenNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(listenSearchData(_:)), name: Notification.Name(rawValue:XBSearchSleepCareHistoryNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDateDidChanged), name: Notification.Name(rawValue:XBDateSelectViewDidSelectDate), object: nil)
    }
    
    //MARK: - Notification
    
    @objc private func listenSearchData(_ aNote:Notification) {
        if !view.isShowingOnKeywindow() {
            return
        }
        beginSearch()
        
    }
    
    @objc func onDateDidChanged() {
        
        if !self.view.isShowingOnKeywindow() {
            return
        }
        makeData()
        
    }
    
    //MARK: - Misc
    
    func beginSearch() {

        if self.group.count == 0 {
            self.view.makeToast(NSLocalizedString("No Data", comment: ""))
            return
        }
        let story = UIStoryboard(name: "XBReportViewController", bundle: Bundle.main)
        let reportVc = story.instantiateViewController(withIdentifier: "reportViewController") as! XBReportViewController
        reportVc.model = self.group[nowTapIndex]
        self.navigationController?.pushViewController(reportVc, animated: true)
        
    }

    //MARK: - Make Data
    
    private func makeData() {
        SVProgressHUD.show()
        XBNetworking.share.postWithPath(path: url, paras: params,
                                        success: { [weak self] (json, message) in
                                            if json[Code].intValue == 1 {
                                                self?.group.removeAll()
                                                self?.selItemIdxSet.removeAll()
                                                var models = [XBSleepData]()
                                                for (_ ,subJson):(String, JSON) in json[XBData] {
                                                    let model = XBSleepData()
                                                    model.add(subJson)
                                                    models.append(model)
                                                }
                                                if self!.needSort {
                                                    self!.sort(&models)
                                                }
                                                self?.group = models
                                                SVProgressHUD.dismiss()
                                                if self!.group.count > 0 {
                                                    if self!.isMember(of: XBSingleSelectHealthHistoryController.self) {
                                                        let firstRow = IndexPath(row: 0, section: 0)
                                                        self!.makeCellChosen(indexPath: firstRow)
                                                    }
                                                } else {
                                                    self!.tableView.reloadData()
                                                }
                                                
                                            } else {
                                                SVProgressHUD.showError(withStatus: message)
                                            }
            }, failure: { (error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
        })
        
    }
    
    
    //MARK: - Private
    
    private func sort(_ array:inout [XBSleepData]) {
        
        if array.count > 0 {
            array.sort(by: { (obj1, obj2) -> Bool in
                return obj1.creatTime > obj2.creatTime
            })
        }
        
    }
    
    fileprivate func makeCellChosen(indexPath:IndexPath) {
    
        for item in group {
            item.selected = false
        }
        self.group[indexPath.row].selected = true
        nowTapIndex = indexPath.row
        
        tableView.reloadData()
    }

}


extension XBSingleSelectHealthHistoryController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.group.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = self.group[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as!XBSleepHistoryTableCell
        cell.model = model
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let model = group[indexPath.row]
        switch indexPath.row % 2 {
        case 0:
            cell.backgroundColor = model.selected == false ? RGBA(r: 236, g: 236, b: 235, a: 1.0) : cellSelectedColor
        default:
            cell.backgroundColor =  model.selected == false ? UIColor.white : cellSelectedColor
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        makeCellChosen(indexPath: indexPath)

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.0
    }
    
}

