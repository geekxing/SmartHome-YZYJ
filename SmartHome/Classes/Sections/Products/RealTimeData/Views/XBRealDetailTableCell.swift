//
//  XBRealDetailTableCell.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/3/23.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBRealDetailTableCell: XBRealDataTableCell {
    
    override var event:Int {
        didSet {
           realtimeState.event = event
        }
    }
    
    var offline:XBSquareButton!
    var onBed:XBSquareButton!
    var motivate:XBSquareButton!
    var noBody:XBSquareButton!
    var realtimeState:XBDisplayRealStateView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let margin = CGFloat(20)
        noBody.top = margin
        noBody.right = width - margin
        motivate.top = margin
        motivate.right = noBody.right - UIRate*50
        onBed.top = margin
        onBed.right = motivate.right - UIRate*50
        offline.top = margin
        offline.right = onBed.right - UIRate*50
        
        realtimeState.left = UIRate * 33
        realtimeState.top = onBed.bottom + 30
        realtimeState.width = width - UIRate * 66
        realtimeState.height = 150
    }
    
    override func setup() {
        super.setup()
        valueLabel.isHidden =  true
        self.shouldEnableEcgDisplay = false
        offline = self.pileButton(#imageLiteral(resourceName: "offline"), title: NSLocalizedString("Off-Line", comment: ""))
        onBed = self.pileButton(#imageLiteral(resourceName: "onBed"), title: NSLocalizedString("In bed", comment: ""))
        motivate = self.pileButton(#imageLiteral(resourceName: "motivate"), title: NSLocalizedString("Body\nmoving", comment: ""))
        noBody = self.pileButton(#imageLiteral(resourceName: "nobody"), title: NSLocalizedString("nobody", comment: ""))
        realtimeState = XBDisplayRealStateView(frame: CGRect.zero)
        addSubview(realtimeState)
        
    }
    
    
    private func pileButton(_ img:UIImage, title:String) -> XBSquareButton {
        let btn = XBSquareButton()
        btn.setImage(img, for: .normal)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIRate*14)
        btn.setTitleColor(XB_DARK_TEXT, for: .normal)
        btn.width = UIRate*30
        btn.height = UIRate*45
        contentView.addSubview(btn)
        return btn
    }


}
