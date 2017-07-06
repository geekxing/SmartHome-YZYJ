//
//  XBMultiReportViewController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/3/23.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBMultiReportViewController: XBBaseViewController {
    
    //MARK: - Properties
    let scrollView  = XBMultiReportView()
    var viewArray = [XBSingleReportView]()
    let titles = [NSLocalizedString("Heart Rate", comment: ""),
                  NSLocalizedString("Respiration", comment: ""),
                  NSLocalizedString("Deep Sleep Amount", comment: ""),
                  NSLocalizedString("Sleep Quality Curve", comment: "")]
    let danweis = [NSLocalizedString("bpm", comment: ""),
                   NSLocalizedString("bpm", comment: ""),
                   NSLocalizedString("h", comment: ""),
                   NSLocalizedString("", comment: "")]
    var heartGroups = [Double]()
    var breathGroups = [Double]()
    var deepSleeps = [Double]()
    var sleeps = [Double]()
    var sleepQuality = [Double]()
    var modelArray = [XBSleepData]() {
        didSet {
            for model in modelArray {
                heartGroups.append(Double(model.avgHeart))
                breathGroups.append(Double(model.avgBreath))
                deepSleeps.append(model.deepSleepTime / 3600)
                sleeps.append(model.sleepTime())
                sleepQuality.append(Double(model.score))
            }
        }
    }

    //MARK: - Overrides
    override var naviBackgroundImage: UIImage? {
        return UIImage(named: "RectHeader")
    }
    
    override var naviTitle: String? {
        return NSLocalizedString("DATA ANALYSIS", comment: "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        scrollView.frame = CGRect(x: 0, y: naviBackgroundImage!.size.height * UIRate, width: view.width, height: view.height)
        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.width, height: 1270)
        
        for i in 0..<4 {
            var report:XBSingleReportView!
            if i == 2 {
                report = XBDoubleSetLineView(frame:CGRect(x: 0, y: 128 + i * (244+19), width: Int(view.width), height: 244))
            } else {
                report = XBSingleReportView(frame:CGRect(x: 0, y: 128 + i * (244+19), width: Int(view.width), height: 244))
            }
            let shawdow = UIImageView(image: #imageLiteral(resourceName: "shadowR"))
            shawdow.left = 0
            shawdow.top = report.bottom
            shawdow.width = view.width
            
            scrollView.addSubview(report)
            scrollView.addSubview(shawdow)
            
            viewArray.append(report)
            report.tag = i
        }
        
        makeData()
        
    }
    
    //MARK: - Private
    private func makeData() {
        
        if modelArray.count > 0 {
            
            scrollView.refresh( Date(timeIntervalSince1970: modelArray.first!.creatTime),
                                end: Date(timeIntervalSince1970: modelArray.last!.creatTime),
                                count: modelArray.count)
        }
        
        for report in viewArray {
            let i = report.tag
            report.title = titles[i]
            report.danwei = danweis[i]
        }
        viewArray[0].datas = heartGroups
        viewArray[1].datas = breathGroups
        let doubleSetView = viewArray[2] as! XBDoubleSetLineView
        doubleSetView.beginValue = 0
        doubleSetView.datas = deepSleeps
        doubleSetView.datasB = sleeps
        viewArray[3].datas = sleepQuality
    }
    
    
}
