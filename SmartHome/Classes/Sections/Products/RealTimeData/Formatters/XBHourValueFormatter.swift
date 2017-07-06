//
//  XBHourValueFormatter.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/3/24.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import Charts

class XBHourValueFormatter: NSObject,IAxisValueFormatter  {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "\(Int(value))h"
    }

}
