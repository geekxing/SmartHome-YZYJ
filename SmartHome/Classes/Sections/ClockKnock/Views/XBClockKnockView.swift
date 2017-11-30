//
//  XBClockKnockView.swift
//  SmartHome
//
//  Created by apple on 2017/11/30.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import UserNotifications

class XBClockKnockView: UIView, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    static let reuseid = "reuseId"
    
    private let datePickButton:UIButton = UIButton(type: .custom)
    private let doneButton:UIButton = UIButton(type: .custom)
    private let contentField = UITextField()
    private let tableView = UITableView()
    
    private var data = [Dictionary<String, String>]() {
        didSet {
            print("did set.")
            //监听数据的变化
            let acc = XBLoginManager.shared.currentLoginData!.account + "clock"
            UserDefaults.standard.set(data, forKey: acc)
            UserDefaults.standard.synchronize()
            UIApplication.shared.applicationIconBadgeNumber = data.count
        }
    }

    private lazy var datePicker:UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .dateAndTime
        dp.minimumDate = Date()
        return dp
    }()
    
    lazy var dateFormatter:DateFormatter? = {
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = SYS_LANGUAGE_CHINESE ? "yyyy/MM/dd HH:mm" :"MM/dd/yyyy HH:mm"
        return dateFmt
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUp() {
        self.backgroundColor = UIColor.white
        
        self.addSubview(self.datePickButton)
        self.addSubview(self.doneButton)
        self.addSubview(self.contentField)
        self.addSubview(self.tableView)
        self.datePickButton.backgroundColor = UIColor.red
        self.datePickButton.setTitle(dateFormatter?.string(from: Date()), for: .normal)
        self.datePickButton.addTarget(self, action: #selector(showTimePicker), for: .touchUpInside)
        self.doneButton.backgroundColor = UIColor.blue
        self.doneButton.setTitle(NSLocalizedString("DONE", comment: ""), for: .normal)
        self.doneButton.addTarget(self, action: #selector(setNote), for: .touchUpInside)
        self.contentField.borderStyle = .roundedRect
        self.contentField.placeholder = NSLocalizedString("Leave messages to remind yourself", comment: "")
        self.contentField.delegate = self
        self.tableView.backgroundColor = UIColor.yellow
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue:XBLocalNotificationNotification), object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.datePickButton.size = CGSize(width: self.width-50, height: 44)
        self.datePickButton.centerX = self.width * 0.5
        self.datePickButton.top = 20
        
        self.contentField.size = CGSize(width: self.width-50, height: 44)
        self.contentField.centerX = self.width * 0.5
        self.contentField.top = self.datePickButton.bottom + 20
        
        self.doneButton.size = CGSize(width: 100, height: 44)
        self.doneButton.centerX = self.width * 0.5
        self.doneButton.top = self.contentField.bottom + 20
        
        self.tableView.frame = CGRect(x: 25, y: self.doneButton.bottom + 15, width: self.width-50, height: self.height - self.doneButton.bottom - 30)
    }
    
    @objc func refresh() {
        let acc = XBLoginManager.shared.currentLoginData!.account + "clock"
        let data = (UserDefaults.standard.value(forKey: acc) ?? []) as! [Dictionary<String, String>]
        setDatasource(data)
    }
    
    func setDatasource(_ data:[Dictionary<String, String>]) {
        //从外界传数据源进来
        self.data = data
        self.tableView.reloadData()
    }
    
    //MARK: Actions
    @objc private func showTimePicker() {
        if let fireDate = dateFormatter?.date(from: self.datePickButton.currentTitle ?? "") {
            self.datePicker.date = fireDate
            self.contentField.inputView = self.datePicker
            self.contentField.reloadInputViews()
            self.contentField.becomeFirstResponder()
        }
    }
    
    @objc private func setNote() {
        self.contentField.resignFirstResponder()
        if let fireDate = dateFormatter?.date(from: self.datePickButton.currentTitle ?? "") {
            if fireDate.timeIntervalSinceNow <= -55 {  ///超过一分钟的日期算过期
                UIAlertView(title: NSLocalizedString("fireDate overdue", comment: ""), message:nil, delegate: nil, cancelButtonTitle: NSLocalizedString("DONE", comment: "")).show()
                return
            }
            let puuid = CFUUIDCreate(nil)
            let uuidString = CFUUIDCreateString(nil, puuid)
            let id = CFStringCreateCopy(nil, uuidString) as String
            let userInfo = ["fireDate":self.datePickButton.currentTitle ?? "",        "content":self.contentField.text ?? "", "id":id]
            if #available(iOS 10.0, *) {
                let content = UNMutableNotificationContent()
                content.title = NSLocalizedString("Clock", comment: "")
                content.body = self.contentField.text ?? ""
                content.badge = 1
                content.userInfo = userInfo as [AnyHashable:AnyObject]
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(fireDate.timeIntervalSinceNow, 1), repeats: false)
                
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                    if error == nil {
                        DispatchQueue.main.async(execute: {
                            print("发送本地通知成功")
                            self.appendData(userInfo)
                        })
                    }
                })
            } else {
                let localNote = UILocalNotification()
                localNote.fireDate = fireDate
                localNote.alertBody = self.contentField.text
                if #available(iOS 8.2, *) {
                    localNote.alertTitle = NSLocalizedString("Clock", comment: "")
                }
                localNote.applicationIconBadgeNumber = 1
                localNote.userInfo = userInfo as [AnyHashable:AnyObject]
                
                // 调用通知
                UIApplication.shared.scheduleLocalNotification(localNote)
                self.appendData(userInfo)
            }
        }
    }
    
    private func appendData(_ userInfo: [String:String]) {
        data.append(userInfo)
        self.tableView.insertRows(at: [IndexPath.init(row: data.count-1, section: 0)], with: .automatic)
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.contentField.inputView != nil { //在选择时间的时候结束编辑才赋值
            self.datePickButton.setTitle(dateFormatter?.string(from: self.datePicker.date), for: .normal)
        }
        self.contentField.inputView = nil
        self.contentField.reloadInputViews()
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: XBClockKnockView.reuseid)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: XBClockKnockView.reuseid)
        }
        let userInfo = data[indexPath.row]
        cell?.textLabel?.text = userInfo["fireDate"]
        cell?.detailTextLabel?.text = userInfo["content"]
        
        return cell!
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return NSLocalizedString("Delete", comment: "")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let userInfo = data[indexPath.row]
            data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if #available(iOS 10.0, *) {
                if let identifier = userInfo["id"] {
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }

}
