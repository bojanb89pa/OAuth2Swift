//
//  Health.swift
//  OAuth2Swift
//
//  Created by Bojan Bogojevic on 8/15/18.
//  Copyright © 2018 Gecko Solutions. All rights reserved.
//

import UIKit
import ObjectMapper

public class Health: BaseModel {
    
    var status: String?
    
    override public func mapping(map: Map) {
        status <- map["status"]
    }
}
