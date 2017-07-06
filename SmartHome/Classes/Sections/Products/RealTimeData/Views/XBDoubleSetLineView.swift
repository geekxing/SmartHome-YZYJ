//
//  XBDoubleSetLineView.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/3/23.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import Charts

class XBDoubleSetLineView:XBSingleReportView  {
    
    private let legend1 = XBButton()
    private let legend2 = XBButton()
    
    var pointYsB = [Double]()
    
    var datasB = [0.0] {
        didSet {
            if datasB.count != 0 {
                pointYsB = datasB
                setChartDataB()
            }
        }
    }
    
    override var rightYLabelFormat:String {   //右边坐标label展示数据格式转化的字符串的format
        return "%.1f"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        legend1.width = 105
        legend1.height = 20
        legend1.right = width - 30
        legend1.top = titleLabel.centerY
        
        legend2.width = 105
        legend2.height = 20
        legend2.right = width - 30
        legend2.top = legend1.bottom
        
        legend1.xb_imageView.left = 0
        legend2.xb_imageView.left = 0
        legend1.xb_label.right = legend1.width
        legend2.xb_label.right = legend1.width
        legend1.xb_imageView.centerY = legend1.xb_label.centerY
        legend2.xb_imageView.centerY = legend2.xb_label.centerY
    }
    
    //MARK: - Draw Code
    
    override func draw(_ rect: CGRect) {
        
        let imageHeight = #imageLiteral(resourceName: "good").size.height
        let xMargin = 22-imageHeight
        let padding = height - 39 - imageHeight / 2
        
        #imageLiteral(resourceName: "bad").draw(at: CGPoint(x: xMargin, y: padding - CGFloat(3-beginValue) * yScale))
        #imageLiteral(resourceName: "soso").draw(at: CGPoint(x: xMargin, y: padding - CGFloat(5-beginValue) * yScale))
        #imageLiteral(resourceName: "good").draw(at: CGPoint(x: xMargin, y: padding - CGFloat(8-beginValue) * yScale))
        
    }
    
    
    //MARK: - Setup And Charts API
    
    override func setup() {
        super.setup()
        
        makeLegends()
        
        let leftAxis = lineChart.leftAxis
        leftAxis.enabled = true
        leftAxis.drawAxisLineEnabled = true
        leftAxis.axisLineColor = XB_DARK_TEXT
        leftAxis.axisLineWidth = 1
        leftAxis.axisMaximum = 12
        leftAxis.axisMinimum = 0
        leftAxis.drawLabelsEnabled = true
        leftAxis.labelCount = 5
        leftAxis.labelPosition = .outsideChart
        leftAxis.labelFont = UIFontSize(10)
        leftAxis.labelTextColor = XB_DARK_TEXT
        leftAxis.valueFormatter = XBHourValueFormatter()
        leftAxis.drawGridLinesEnabled = false
    }
    
    private func makeLegends() {
        
        addSubview(legend1)
        addSubview(legend2)
        
        legend1.xb_imageView.image = UIImage.imageWith(UIColorHex("c6bdb5", 1))
        legend1.xb_imageView.sizeToFit()
        legend1.xb_imageView.width = #imageLiteral(resourceName: "legend2").size.width
        legend1.xb_label.text = NSLocalizedString("Total Sleep", comment: "")
        legend1.xb_label.textColor = XB_DARK_TEXT
        legend1.xb_label.font = UIFontSize(10)
        legend1.xb_label.textAlignment = .right
        legend1.xb_label.sizeToFit()
        
        legend2.xb_imageView.image = #imageLiteral(resourceName: "legend2")
        legend2.xb_imageView.sizeToFit()
        legend2.xb_label.text = NSLocalizedString("Deep Sleep", comment: "")
        legend2.xb_label.textColor = XB_DARK_TEXT
        legend2.xb_label.font = UIFontSize(10)
        legend2.xb_label.textAlignment = .right
        legend2.xb_label.sizeToFit()
        
    }
    
    private func setChartDataB() {
        
        var yVals = [ChartDataEntry]()
        for i in 0..<pointYsB.count {
            yVals.append(ChartDataEntry(x: Double(CGFloat(i) * xScale), y: Double(pointYsB[i])))
        }
        
        let dataSet = LineChartDataSet(values: yVals, label: "")
        dataSet.mode = .cubicBezier
        dataSet.drawCirclesEnabled = false
        dataSet.setColor(UIColorHex("c6bdb5", 1))
        
        if let firstDS = lineDataSet {
            firstDS.fillAlpha = 1
            
            let gradientColors =
                [RGBA(r: 240, g: 238, b: 237, a: 1).cgColor,
                 RGBA(r: 210, g: 210, b: 210, a: 1).cgColor]
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)
            firstDS.fill = Fill(linearGradient: gradient!, angle: 90.0)
            firstDS.drawFilledEnabled = true
        }

        lineData = LineChartData(dataSets: [lineDataSet!, dataSet])
        lineData!.setDrawValues(false)
        lineChart.data = lineData
        
    }
    
    //MARK: - Misc
    
    override func makeScoreAttributeString(score:String, text:String) -> NSAttributedString {
        return NSMutableAttributedString(string: score + text, attributes: [NSFontAttributeName:UIFontSize(10)])
    }
    

}
