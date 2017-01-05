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
    
    public func toDict() -> [String:Any] {
        var dict = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = unwrap(any: child.value)
                
            }
        }
        return dict
    }
    
    private func unwrap(any:Any) -> Any {
        
        let mi = Mirror(reflecting: any)
        if mi.displayStyle != Mirror.DisplayStyle.optional {
            return any
        }
        
        if mi.children.count == 0 { return NSNull() }
        let (_, some) = mi.children.first!
        return some
        
    }
}
