//
//  XBMultiReportView.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/3/23.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBMultiReportView: UIScrollView {
    
    private var max:UIButton!
    private var avg:UIButton!
    private var min:UIButton!
    private var dateLabel:UILabel!
    private var countLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.backgroundColor = RGBA(r: 198, g: 189, b: 182, a: 1)
        
        dateLabel = makeLabel()
        countLabel = makeLabel()
        
        max = makeButton(#imageLiteral(resourceName: "up"), title: NSLocalizedString("Maximum", comment: ""))
        avg = makeButton(#imageLiteral(resourceName: "mid"), title: NSLocalizedString("Average", comment: ""))
        min = makeButton(#imageLiteral(resourceName: "down"), title: NSLocalizedString("Minimum", comment: ""))

        self.dateLabel.text = String(format: NSLocalizedString("DATA_ANALYSIS_DATE_PERIOD", comment: ""), "*","*","*","*")
        self.dateLabel.sizeToFit()
        self.countLabel.text = "共计次数：*次"
        self.countLabel.sizeToFit()
        
    }
    
    func refresh(_ begin:Date, end:Date, count:Int) {

        self.dateLabel.text = String(format: NSLocalizedString("DATA_ANALYSIS_DATE_PERIOD", comment: ""), begin.shortMonthName,begin.day,end.shortMonthName,end.day)
        self.dateLabel.sizeToFit()
        self.countLabel.text = String(format: NSLocalizedString("DATA_ANALYSIS_TOTAL_REPORTS", comment: ""), count)
        self.countLabel.sizeToFit()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dateLabel.left = 25
        dateLabel.top = 12
        countLabel.left = 25
        countLabel.top = dateLabel.bottom + 12
        max.right = width - 25
        max.top = 16
        avg.left = max.left
        avg.top = max.bottom + 16
        min.left = max.left
        min.top = avg.bottom + 16
    }
    
    //MARK:- Private
    
    private func makeButton(_ img:UIImage, title:String) -> UIButton {
        let btn = UIButton()
        btn.setImage(img, for: .normal)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0)
        btn.titleLabel?.textAlignment = .center
        btn.sizeToFit()
        addSubview(btn)
        return btn
    }
    
    private func makeLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.white
        addSubview(label)
        return label
    }

}
