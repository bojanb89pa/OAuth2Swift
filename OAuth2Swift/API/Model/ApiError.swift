//
//  ApiError.swift
//  OAuth2Swift
//
//  Created by Bojan Bogojevic on 1/12/17.
//  Copyright © 2017 Gecko Solutions. All rights reserved.
//

import UIKit
import ObjectMapper

class ApiError: BaseModel {
    
    var code: Int?
    var error: String?
    
    required public init?(map: Map){
        super.init(map: map)
    }
    
    init(code: Int = 0, error: String){
        super.init()!
        self.code = code
        self.error = error
    }
    
    override public func mapping(map: Map) {
        code <- map["code"]
        error <- map["error"]
    }
}
