//
//  XBMainView.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2016/12/4.
//  Copyright © 2016年 helloworld.com. All rights reserved.
//

import UIKit
import SDWebImage

class XBMainView: UIView {
    
    static let edgeMargin = CGFloat(46.0*UIRate)
    var buttonW: CGFloat {
        return  69.0*1.5*UIRate
    }
    var buttonH: CGFloat {
        return 100.0*1.5*UIRate
    }
    
    //Properties
    
    let btnColor = UIColor(white: 0/255.0, alpha: 0.2)
  
    var avatarRing:UIImageView!
    var avatarView:UIImageView!
    var nameLabel:UILabel!
    var currentUser:XBUser = XBUser() {
        didSet {
            avatarView.setHeader(url: currentUser.image, uid: currentUser.email)
            nameLabel.text = currentUser.Name()
            nameLabel.sizeToFit()
        }
    }
    
    var mainItems:[MainItemModel] {
        let btnTitles =
            [NSLocalizedString("Smart\nMattress Pad", comment: ""),
//             NSLocalizedString("Smart\nPillow", comment: ""),
//             NSLocalizedString("Baby\nMattress Pad", comment: ""),
             NSLocalizedString("Family\nCare", comment: ""),
             NSLocalizedString("Alarm Time\nNotes Massage Inform", comment: "")]
//             NSLocalizedString("Value-Added\nServices", comment: ""),
//             NSLocalizedString("Doctor's Hall", comment: "")]
        let btnImages = ["Sbed", /**"Spillow","Sring",*/ "Relation",/** "Product",*/ "Doctor"]
        let itemEnables = [true, true, true]
        var array = [MainItemModel]()
        for i in 0..<btnTitles.count {
            let mainitem = MainItemModel(image: btnImages[i], title:btnTitles[i], enabled:itemEnables[i], backImage:"")
            array.append(mainitem)
        }
        return array
    }
    
    lazy var squareBtns:[XBSquareButton] = {[]}()
    
    var clickSquare:((UIButton) -> ())?
    var tapAvatar:((XBUser) -> ())?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        setupUserPart()
        pileButton()
        let userMgr = XBUserManager.shared
        if let uid = userMgr.currentAccount() {
            if let user = userMgr.user(uid: uid) {
                self.currentUser = user
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame.origin = CGPoint(x: avatarView.centerX - nameLabel.width/2, y: avatarView.bottom + 6)
    }
    
    //MARK: - Setup
    
    private func setupUserPart() {
        
        let ring = #imageLiteral(resourceName: "avatarRing")
        avatarRing =  UIImageView(image:ring)
        avatarRing.size = CGSize(width: ring.size.width*UIRate, height: ring.size.height*UIRate)
        avatarRing.centerX = self.centerX
        avatarRing.top = 48*UIRate
        
        let wh = 112*UIRate
        let gap = (avatarRing.width - wh) / 2
        avatarView = UIImageView(frame:CGRect(x: 0 ,y: 0, width: wh, height: wh))
        avatarView.centerX = self.centerX
        avatarView.layer.cornerRadius = avatarView.height/2
        avatarView.layer.masksToBounds = true
        avatarView.layer.shadowOffset = CGSize(width: 1, height: 1)
        avatarView.layer.shadowColor = UIColor.black.cgColor
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAvatar(tap:))))
        avatarView.top = avatarRing.top+gap
        avatarView.centerX = self.centerX
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.textColor = XB_DARK_TEXT

        addSubview(avatarRing)
        addSubview(avatarView)
        addSubview(nameLabel)
    }
    
    private func pileButton() {
        let maxColsCount = 2/*mainItems.count / 2*/
        
        for i in 0..<mainItems.count {
            
            let mainItem = self.mainItems[i]
            let interMargin = self.interMargin(numPerRow: maxColsCount)
            var x = CGFloat(XBMainView.edgeMargin)
            x += CGFloat(i%maxColsCount)*(CGFloat(interMargin)+buttonW)
            
            let square = XBSquareButton(image: UIImage(named: mainItem.image!), backImage: UIImage(named: mainItem.backImage!), color:nil, target: self, sel: #selector(click(btn:)), title:mainItem.title)
            
            square.isEnabled = mainItem.enabled
            square.tag = i
            var y  = CGFloat(0)
            if i < maxColsCount {
                y = CGFloat( 289 * UIRateH )
            } else {
                y = CGFloat( 448.0 * UIRateH)
            }
            square.frame = CGRect(x: x, y: y, width: buttonW, height: buttonH)
            self.squareBtns.append(square)
            addSubview(square)
            
        }
    }
    
    private func interMargin(numPerRow:Int) -> CGFloat {
        //（宽-2*边距-3*按钮宽）/2
        return (bounds.width - 2*XBMainView.edgeMargin - CGFloat(CGFloat(numPerRow)*buttonW))/CGFloat(numPerRow-1 > 0 ? numPerRow-1 : 1)
    }
    
    //MARK: - action

    @objc private func click(btn:UIButton) {
        if (clickSquare != nil) {
            clickSquare!(btn)
        }
    }
    
    @objc private func tapAvatar(tap:UITapGestureRecognizer) {
        if tapAvatar != nil {
            tapAvatar!(self.currentUser)
        }
    }
}
