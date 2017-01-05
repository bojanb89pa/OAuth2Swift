//
//  BaseModel.swift
//  OAuth2Swiftn//
//  Created by Bojan Bogojevic on 1/5/17.
//  Copyright © 2017 Gecko Solutions. All rights reserved.
//

import UIKit
import ObjectMapper

public class BaseModel: Mappable {
    
    required public init?(map: Map){}
    public init?(){}
    public func mapping(map: Map){}
}
