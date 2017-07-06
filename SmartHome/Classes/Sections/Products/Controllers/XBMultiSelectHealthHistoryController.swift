//
//  XBMultiSelectHealthHistoryController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/25.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import SVProgressHUD

class XBMultiSelectHealthHistoryController: XBSingleSelectHealthHistoryController {
    
    override var needSort:Bool {
        return false
    }
    
    override var group: [XBSleepData] {
        didSet {
            if group.count >= 1 {
                let enumrator = group.enumerated()
                for (index, obj) in enumrator {
                    obj.selected = true
                    selItemIdxSet.insert(index)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    override var url:String {
        return type == .me ? DEVICE_DATA : DEVICE_OTHERDATA
    }
    
    override var params:[String:String] {
        
        let startTime = headerView.beginDate.string(format: .custom("MM/dd/yyyy"))
        let endTime =  headerView.endDate.string(format: .custom("MM/dd/yyyy"))
        
        var params:Dictionary = ["token":token,
                                 "startTime":startTime,
                                 "endTime":endTime]
        if type == .other {
            params["email"] = other!.email
        }
        return params
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupHeader() {
        headerView = XBHealthCareHeaderView(.multiple)
        headerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 198)
    }
    
    override func beginSearch() {
        
        let selectModels = (group as NSArray).objects(at: selItemIdxSet) as! [XBSleepData]
        if self.group.count == 0 {
            self.view.makeToast(NSLocalizedString("No Data", comment: ""))
            
        } else if selectModels.count <= 1 {
            self.view.makeToast(NSLocalizedString(NSLocalizedString("Select one period from the list", comment: ""), comment: ""))
            
        } else {
            let mutiVC = XBMultiReportViewController()
            mutiVC.modelArray = selectModels
            self.navigationController?.pushViewController(mutiVC, animated: true)
        }
        
    }
    
    override func onDateDidChanged() {
        if headerView.beginDate.add(components: [.month : 3]).isBefore(date: headerView.endDate, granularity: .day) {
            self.view.makeToast(NSLocalizedString("The period you select is too long", comment: ""))
            return
        }
        super.onDateDidChanged()
    }
    
    //MARK: - Private
    fileprivate func makeCellChosen() {

        //1.清理所有条目的选中状态
        for item in group {
            item.selected = false
        }
        //2.判断当前点选条目的选中状态
        if selItemIdxSet.count == 0 {
            selItemIdxSet.insert(nowTapIndex)
        } else if selItemIdxSet.contains(nowTapIndex) {
            selItemIdxSet.remove(nowTapIndex)
        } else {
            if nowTapIndex < selItemIdxSet.first! {
                selItemIdxSet.insert(integersIn: nowTapIndex ..< selItemIdxSet.first!)
            } else if nowTapIndex > selItemIdxSet.last! {
                selItemIdxSet.insert(integersIn: selItemIdxSet.last!+1 ... nowTapIndex)
            } else {
                selItemIdxSet.insert(nowTapIndex)
            }
        }
        
        if selItemIdxSet.count != 0 {
            selItemIdxSet.forEach({ (idx) in
                group[idx].selected = true
            })
        }
        
        tableView.reloadData()
    }
    
}

extension XBMultiSelectHealthHistoryController {

    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        nowTapIndex = indexPath.row
        
        makeCellChosen()
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let model = group[indexPath.row]
        cell.backgroundColor = !model.selected ? UIColor.white : cellSelectedColor
    }
    
}
