//
//  XBProductMainView.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/1/15.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBProductMainView: XBMainView {
    
    override var mainItems:[MainItemModel] {
        let btnTitles =
            [NSLocalizedString("Real-time\nData", comment: ""),
             NSLocalizedString("Health\nArchives", comment: ""),
             NSLocalizedString("Add Device", comment: ""),
             NSLocalizedString("Delete\nDevice", comment: "")]
        let btnImages = ["RealTimeData", "HealthReport", "AddDevice", "DeleteDevice"]
        let itemEnables = [true, true, true, true]
        var array = [MainItemModel]()
        for i in 0..<4 {
            let mainitem = MainItemModel(image: "", title:btnTitles[i], enabled:itemEnables[i], backImage:btnImages[i])
            array.append(mainitem)
        }
        return array
    }
    
    override var buttonW: CGFloat {
        return 117.0*UIRate;
    }
    
    override var buttonH: CGFloat {
        return 117.0*UIRate;
    }
    
    func toggleFunctionEnabled(sn:String?) {
        if sn != "" && sn != nil {
            for btn in squareBtns {
                btn.isEnabled = true
            }
        } else {
            for i in 0..<squareBtns.count {
                let btn = squareBtns[i]
                btn.isEnabled = i == 2
            }
        }
    }

}
