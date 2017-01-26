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
    var error: String? {
        willSet {
            if let nValue = newValue {
                localizedError = NSLocalizedString("error.\(nValue)", value: "Error occurred!", comment: "\(nValue)")
            }
        }
    }
    
    var localizedError: String? = NSLocalizedString("error.DEFAULT_ERROR", value: "Error occurred!", comment: "DEFAULT_ERROR")
    
    required public init?(map: Map){
        super.init(map: map)
    }
    
    
    init(_ code: Int = 0,_ error: String = "DEFAULT_ERROR"){
        super.init()!
        self.code = code
        self.error = error
    }
    
    override public func mapping(map: Map) {
        code <- map["code"]
        error <- map["error"]
    }
}
