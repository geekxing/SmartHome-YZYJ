//
//  XBRelationConcernModel.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/1/16.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

let SearchApply  = "SearchApply"
let ApplyConcern = NSLocalizedString("Approve the Request", comment: "")
let MyConcern    = "我的关注"
let ConcernMe    = NSLocalizedString("Already Care Me", comment: "")

class XBRelationConcernModel: NSObject {

    var user:XBUser!
    var tag:String!
    
    var open:Bool = false
    
}
