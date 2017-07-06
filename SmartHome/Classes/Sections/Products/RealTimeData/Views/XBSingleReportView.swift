//
//  XBSingleReportView.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/3/23.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import Charts

class XBSingleReportView: UIView {
    
    //MARK: - Properties
    let drawHeight = CGFloat(145.0)  //Debug测得的实际绘图区域高度
    var rightYLabelFormat:String {   //右边坐标label展示数据格式转化的字符串的format
        return "%.0f"
    }
    var title: String = "" {
        didSet {
            titleLabel.text = title
            titleLabel.sizeToFit()
        }
    }
    var beginValue = -1.0
    var lineDataSet:LineChartDataSet?
    var lineData:LineChartData?
    
    private(set) var maxPoint = 0.0
    private(set) var avgPoint = 0.0
    private(set) var lowPoint = 0.0
    private(set) var xScale = CGFloat(0.0)
    private(set) var yScale = CGFloat(0.0)
    private(set) var pointYs = [Double]()
    
    private var maxButton:UIButton!
    private var avgButton:UIButton!
    private var minButton:UIButton!
    var lineChart:LineChartView!
    
    var datas = [0.0] {
        didSet {
            if datas.count != 0 {
                
                xScale = (self.width-90)/CGFloat(datas.count) //比例：宽度/x轴分度
                
                ///计算最大值
                maxPoint = maxOf(numbers: datas)
                ///计算平均值
                avgPoint = averageOf(numbers: datas)
                if self.rightYLabelFormat == "%.0f" {  ///需要取整的数值平均值做四舍五入
                    avgPoint = round(avgPoint)
                }
                ///计算最小值
                lowPoint = minOf(numbers: datas)
                if beginValue == -1 {
                    beginValue = lowPoint
                }
                //算出y轴最值，并赋给y轴
                let maxY = max(lineChart.leftAxis.axisMaximum, maxPoint)
                
                yScale = maxY-beginValue == 0 ? 0 : drawHeight / CGFloat(maxY-beginValue) //比例：高度/y轴分度
                pointYs = datas
                setChartData()
                drawLimitLine()
                
                let maxStr = String(format: rightYLabelFormat, maxPoint)
                let avgStr = String(format: rightYLabelFormat, avgPoint)
                let minStr = String(format: rightYLabelFormat, lowPoint)
                maxButton.setAttributedTitle(self.makeScoreAttributeString(score: maxStr, text: danwei), for: .normal)
                maxButton.sizeToFit()
                avgButton.setAttributedTitle(self.makeScoreAttributeString(score: avgStr, text: danwei), for: .normal)
                avgButton.sizeToFit()
                minButton.setAttributedTitle(self.makeScoreAttributeString(score: minStr, text: danwei), for: .normal)
                minButton.sizeToFit()
                //setNeedsDisplay()
            }
        }
    }
    
    var danwei:String = ""
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.left = 22
        titleLabel.top  = 22
        
        lineChart.width = width - titleLabel.left - UIRate * 60
        lineChart.height = drawHeight + 20
        lineChart.left = 22
        lineChart.top = 50
        
        ///Chart最小值与绘图框的padding设置为5
        let padding = height - 39
        minButton.left = lineChart.right
        minButton.centerY = padding - CGFloat(lowPoint-beginValue) * yScale
        avgButton.left = lineChart.right
        avgButton.centerY = padding - CGFloat(avgPoint-beginValue) * yScale
        maxButton.left = lineChart.right
        maxButton.centerY = padding - CGFloat(maxPoint-beginValue) * yScale
        
        if avgPoint != maxPoint && avgPoint != lowPoint {
            if minButton.frame.intersects(avgButton.frame) {
                minButton.top = avgButton.bottom
            }
            if maxButton.frame.intersects(avgButton.frame) {
                maxButton.bottom = avgButton.top
            }
        } else { //如果平均线有重叠的就不画了
            avgButton.isHidden = true
        }
     
    }
    
    //MARK: - Setup
    func setup() {
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 23
        self.layer.masksToBounds = true
        titleLabel.font = UIFont.boldSystemFont(ofSize: UIRate*20)
        titleLabel.textColor = XB_DARK_TEXT
        addSubview(titleLabel)
        makeChart()
        
        maxButton = makeButton(#imageLiteral(resourceName: "up_small"))
        avgButton = makeButton(#imageLiteral(resourceName: "round_small"))
        minButton = makeButton(#imageLiteral(resourceName: "down_small"))
        addSubview(maxButton)
        addSubview(avgButton)
        addSubview(minButton)
    }
    
    //MARK: - 画图
    private func makeChart() {
        lineChart = LineChartView()
        addSubview(lineChart)
        lineChart.backgroundColor = UIColor.white
        lineChart.isUserInteractionEnabled = false
        lineChart.noDataText = NSLocalizedString("No Data", comment: "")
        lineChart.scaleYEnabled = false
        lineChart.scaleXEnabled = false
        lineChart.pinchZoomEnabled = false
        lineChart.doubleTapToZoomEnabled = false
        lineChart.dragEnabled = false
        lineChart.xAxis.enabled = false
        lineChart.rightAxis.enabled = false
        lineChart.leftAxis.enabled = true
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawAxisLineEnabled = false
        lineChart.leftAxis.drawLabelsEnabled = false
        lineChart.leftAxis.spaceTop = 0.15
        lineChart.leftAxis.spaceBottom = 0.15
        lineChart.minOffset = 5
        lineChart.chartDescription?.text = "" //描述
        lineChart.legend.enabled = false  //图例说明
        lineChart.animate(yAxisDuration: 1.0)
    }
    
    func drawLimitLine() {
        let ll1 = ChartLimitLine(limit: maxPoint)
        ll1.lineDashLengths = [1,3]
        ll1.lineColor = UIColorHex("343434", 1)
        
        let ll2 = ChartLimitLine(limit: avgPoint)
        ll2.lineDashLengths = [1,3]
        ll2.lineColor = UIColorHex("343434", 1)
        
        let ll3 = ChartLimitLine(limit: lowPoint)
        ll3.lineDashLengths = [1,3]
        ll3.lineColor = UIColorHex("343434", 1)

        let leftYAxis = lineChart.leftAxis
        leftYAxis.removeAllLimitLines()
        leftYAxis.addLimitLine(ll1)
        if avgPoint != maxPoint && avgPoint != lowPoint {
            leftYAxis.addLimitLine(ll2)
        }
        leftYAxis.addLimitLine(ll3)
        
        leftYAxis.axisMaximum = max(leftYAxis.axisMaximum, maxPoint)
        leftYAxis.axisMinimum = min(leftYAxis.axisMinimum, lowPoint)
    }
    
    //MARK: - 图表数据
    private func setChartData() {
        
        var yVals = [ChartDataEntry]()
        for i in 0..<pointYs.count {
            yVals.append(ChartDataEntry(x: Double(CGFloat(i) * xScale), y: Double(pointYs[i])))
        }
        
        let dataSet = LineChartDataSet(values: yVals, label: "")
        dataSet.mode = .cubicBezier
        dataSet.drawCirclesEnabled = false
        dataSet.setColor(UIColor.black)
        
        lineDataSet = dataSet
        
        lineData = LineChartData(dataSet: dataSet)
        lineData!.setDrawValues(false)
        lineChart.data = lineData
    }
    
    //MARK: - misc
    private func makeButton(_ img:UIImage) -> UIButton {
        let btn = UIButton()
        btn.setImage(img, for: .normal)
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.textAlignment = .center
        return btn
    }
    
    func makeScoreAttributeString(score:String, text:String) -> NSAttributedString {
        let scoreAttri = NSMutableAttributedString(string: score, attributes: [NSFontAttributeName:UIFontSize(20)])
        let textAttri = NSMutableAttributedString(string: "\n\(text)", attributes: [NSFontAttributeName:UIFontSize(12)])
        scoreAttri.append(textAttri)
        return scoreAttri
    }


}
