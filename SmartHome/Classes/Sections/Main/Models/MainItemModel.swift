//
//  MainItemModel.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/1/14.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class MainItemModel: NSObject {
    
    init(image:String, title:String, enabled:Bool, backImage:String) {
        self.image = image
        self.title = title
        self.enabled = enabled
        self.backImage = backImage
    }

    public var image:String?
    public var title:String?
    public var enabled:Bool
    public var backImage:String?

}
