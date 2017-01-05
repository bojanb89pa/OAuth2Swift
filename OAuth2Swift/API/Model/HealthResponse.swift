//
//  CheckResponse.swift
//  OAuth2Swiftn//
//  Created by Bojan Bogojevic on 1/4/17.
//  Copyright © 2017 Gecko Solutions. All rights reserved.
//

import UIKit
import ObjectMapper

public class HealthResponse: BaseModel {
    
    var status: String?
    
    override public func mapping(map: Map) {
        status <- map["status"]
    }
}
