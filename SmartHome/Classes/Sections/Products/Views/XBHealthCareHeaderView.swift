//
//  XBHealthCareHeaderView.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/25.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit


class XBHealthCareHeaderView: UIView {
    
    public enum XBHealthCareHeaderViewSelectType : Int {
        
        
        case single
        
        case multiple
        
    }
    
    var beginDate = Date(timeIntervalSinceNow: -7*24*3600) //一周前
    var endDate = Date()
    
    let dateSelectViewH = 33*UIRateH

    private var selectType:XBHealthCareHeaderViewSelectType?
    
    private var selectViewA:XBDateSelectView?
    private var selectViewB:XBDateSelectView?
    private var toLabel = UILabel()
    
    private var shawdowLine:UIImageView!
    private var container:UIView!

    private var titles = [NSLocalizedString("Report Date", comment: ""),
                          NSLocalizedString("Sleep Time", comment: ""),
                          NSLocalizedString("Sleep Score", comment: "")]
    private var tipLabels = [UILabel]()
    
    convenience init(_ type:XBHealthCareHeaderViewSelectType) {
        self.init()
        selectType = type
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        container.width = self.width
        container.height = 48*UIRateH
        container.left = 0
        container.bottom = height
        
        for (index, label) in self.tipLabels.enumerated() {
            let labelWidth = self.width/3
            label.width = labelWidth
            label.left = CGFloat(index) * labelWidth
            label.centerY = container.height * 0.5
        }
        
        shawdowLine.width = width
        shawdowLine.height = 8;
        shawdowLine.left = 0;
        shawdowLine.top  = container.height;
        
        toLabel.centerX = width * 0.5
        toLabel.centerY = (height - container.height) * 0.5
        
        selectViewB?.bottom = self.height - container.height - selectViewA!.top
    }
    
    //MARK: - Public
    func setDate(_ date:Date, for oldDate:inout Date) {
        if self.selectType == .single {
            oldDate = date
            selectViewA?.date = date
        } else {
            if oldDate == self.endDate {
                selectViewB?.date = date
            } else {
                selectViewA?.date = date
            }
        }
    }
    
    //MARK: - Setup
    
    private func setup() {
        if selectType == .single {
            selectViewA = XBDateSelectView(frame: CGRect(x: 0, y: 25.0, width: self.width, height: dateSelectViewH))
            selectViewA?.date = endDate
            selectViewA?.labelTextColor = UIColorHex("595757", 1.0)
            addSubview(selectViewA!)
            selectViewA?.didPickDateBlock = { [weak self] date in
                self?.endDate = date
            }
        } else {
            backgroundColor = RGBA(r: 196, g: 190, b: 183, a: 1.0)
            selectViewA = XBDateSelectView(frame: CGRect(x: 0, y: 25.0*UIRateH, width: self.width, height: dateSelectViewH))
            selectViewA?.date = beginDate
            selectViewA?.labelTextColor = UIColorHex("ffffff", 1.0)
            addSubview(selectViewA!)
            selectViewA?.didPickDateBlock = { [weak self] date in
                self?.beginDate = date
                self?.selectViewB?.beginDate = date
            }
            
            toLabel.text = NSLocalizedString("to", comment: "")
            toLabel.font = UIFontSizeB(16)
            toLabel.textColor = UIColorHex("ffffff", 1.0)
            toLabel.sizeToFit()
            addSubview(toLabel)
            
            selectViewB = XBDateSelectView(frame: CGRect(x: 0, y: 0, width: self.width, height: dateSelectViewH))
            selectViewB?.beginDate = beginDate
            selectViewB?.date = endDate
            selectViewB?.labelTextColor = UIColorHex("ffffff", 1.0)
            addSubview(selectViewB!)
            selectViewB?.didPickDateBlock = { [weak self] date in
                self?.endDate = date
                self?.selectViewA?.datePck?.maximumDate = date
            }
            
            selectViewA?.datePck?.maximumDate = selectViewB?.date
        }
        
        setupContainer()
    }
    
    private func setupContainer() {
        container = UIView(frame: CGRect())
        container.backgroundColor = UIColor.white
        addSubview(container)
        setupLabel()
        setupShadow()
    }
    
    private func setupShadow() {
        shawdowLine = UIImageView(image: UIImage(named: "horizontalShadow"))
        container.addSubview(shawdowLine)
    }
    
    private func setupLabel() {
        for (title) in titles {
            let label = UILabel()
            label.font = UIFontRatioSizeB(16)
            label.textColor = XB_DARK_TEXT
            label.text = title
            label.textAlignment = .center
            label.sizeToFit()
            tipLabels.append(label)
            container.addSubview(label)
        }
    }
    

    
}
