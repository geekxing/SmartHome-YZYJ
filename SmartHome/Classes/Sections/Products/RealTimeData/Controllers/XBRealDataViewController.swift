//
//  XBRealDataViewController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/26.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class XBRealDataViewController: XBBaseViewController {
    
    static var netError:Int = 0
    static let dataCellId = "dataCellId"
    static let detailCellId = "detailCellId"
    var timer:DispatchSourceTimer?
    
    var realData:XBRealData? {
        didSet {}
    }
    var heartBuffer = [Int]()
    var sn:String?
    fileprivate var tableView:UITableView!
    
    override var naviBackgroundImage: UIImage? {
        return UIImage(named: "RectHeader")
    }
    
    override var naviTitle: String? {
        return NSLocalizedString("REAL-TIME DATA", comment: "")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        if self.sn == nil {
            self.sn = loginUser!.Device().first ?? ""
        }
    }
    
    convenience init(_ sn:String?) {
        self.init()
        self.sn = sn
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTimer()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.cancel()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func setupTimer()  {
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        timer?.setEventHandler( handler: {
            self.makeData()
        })
        timer?.scheduleRepeating(deadline: .now(), interval: .seconds(10))
        timer?.resume()
    }
    
    //MARK: - UI Setting
    
    private func setupTableView() {
        
        let naviHeight = (naviBackgroundImage!.size.height)
        tableView = UITableView(frame: CGRect(x: 0, y: naviHeight, width: view.width, height: view.height-naviHeight))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.delaysContentTouches = false
        tableView.register(XBRealDataTableCell.self, forCellReuseIdentifier: XBRealDataViewController.dataCellId)
        tableView.register(XBRealDetailTableCell.self, forCellReuseIdentifier: XBRealDataViewController.detailCellId)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
    }
    
    @objc private func makeData() {
        
        let params:Dictionary = ["sn":sn!]
        
        XBNetworking.share.postWithPath(path: REALDATA, paras: params,
                                        success: { [weak self] (json, message) in
                                            XBRealDataViewController.netError = 0
                                            let message = json[Message].stringValue
                                            if json[Code].intValue == 1 {
                                                let real = XBRealData()
                                                real.add(json[XBData])
                                                self?.realData = real
                                                self?.updateComplete()
                                            } else {
                                                XBRealDataViewController.netError += 1
                                                if XBRealDataViewController.netError == 3 {
                                                    SVProgressHUD.showError(withStatus: message)
                                                }
                                            }
            }, failure: { (error) in
                XBRealDataViewController.netError += 1
                if XBRealDataViewController.netError == 3 {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
        })
    
    }
    
    func updateComplete() {
        
        if self.realData != nil {
            
            //校准心率
            var heart = realData!.heart
            if heart != 0 {
                
                if heartBuffer.count < 2 {
                    heartBuffer.append(heart)
                    
                } else {  //heartBuffer 2,3 ....
                    
                    if heartBuffer.count == 3 {
                        heartBuffer.remove(at: 0)
                    }
                    let buffer = heartBuffer + [heart]
                    heart = modifiedHeart(buffer)
                    realData!.heart = heart
                    heartBuffer.append(heart)
                    
                }
                
                //校准呼吸率
                
                let b = heart / 4
                let t = realData!.breath != 0 ? realData!.breath : b
                let l = b + (t - b) / 3
                
                realData!.breath = l
                
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: XBDrawFrequecyDidChanged), object: nil, userInfo:["obj":Float(realData!.heart)])
            
            self.tableView.reloadData()
        }
        
    }
    
    //MARK: - misc
    
    fileprivate func makeScoreAttributeString(score:String, text:String) -> NSAttributedString {
        let scoreAttri = NSMutableAttributedString(string: score, attributes: [NSFontAttributeName:UIFontSize(26),
                                                                               NSForegroundColorAttributeName:UIColor.black])
        let textAttri = NSMutableAttributedString(string: "\n\(text)", attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 12),
                                                                                    NSForegroundColorAttributeName:XB_DARK_TEXT])
        scoreAttri.append(textAttri)
        return scoreAttri
    }

}

extension XBRealDataViewController: UITableViewDataSource {
    
    //MARK: - UITableViewDatasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = indexPath.row != 2 ?
        XBRealDataViewController.dataCellId : XBRealDataViewController.detailCellId
        
        let cell = tableView.dequeueReusableCell(withIdentifier:identifier) as! XBRealDataTableCell
        if indexPath.row == 0 {
            cell.imageView?.image = #imageLiteral(resourceName: "heart")
            cell.textLabel?.text = NSLocalizedString("Heart\nRate", comment: "")
            cell.shouldEnableEcgDisplay = true
        } else if indexPath.row == 1 {
            cell.imageView?.image = #imageLiteral(resourceName: "breath-1")
            cell.textLabel?.text = NSLocalizedString("Respiration", comment: "")
        } else {
            cell.imageView?.image = #imageLiteral(resourceName: "sleep")
            cell.textLabel?.text = NSLocalizedString("Status", comment: "")
        }
        var score = "--"
        var danwei = ""
        if self.realData != nil {
            if indexPath.row == 0 {
                score = "\(realData!.heart)"
                danwei = NSLocalizedString("bpm", comment: "")
            } else if indexPath.row == 1 {
                score = "\(realData!.breath)"
                danwei = NSLocalizedString("breaths/min", comment: "")
            } else {
                cell.event = realData!.event
            }
        }
        cell.valueLabel.attributedText = self.makeScoreAttributeString(score: score, text: danwei)
        
        return cell
    }
    
}

extension XBRealDataViewController: UITableViewDelegate {
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 138
        case 1: return 138
        default: return 305
        }
    }
    
}
