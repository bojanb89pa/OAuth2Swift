//
//  OAuth2Token.swift
//  OAuth2Swift
//
//  Created by Bojan Bogojevic on 8/15/18.
//  Copyright © 2018 Gecko Solutions. All rights reserved.
//

import Foundation
import ObjectMapper

public class OAuth2Token : BaseModel {
    var accessToken: String?
    var refreshToken: String?
    var expirationDate: Date!
    var expiresIn: Int! {
        willSet(newValue) {
            if let value = newValue {
                expirationDate = Date.init(timeIntervalSince1970: Date().timeIntervalSince1970 + Double(value))
            }
        }
    }
    
    override init?() {
        super.init()
    }
    
    required public init?(map: Map){
        super.init(map: map)
    }
    
    override public func mapping(map: Map) {
        accessToken <- map["access_token"]
        refreshToken <- map["refresh_token"]
        expiresIn <- map["expires_in"]
    }
    
    func isExpired() -> Bool {
        if let expDate = expirationDate {
            if(Date().compare(expDate) == ComparisonResult.orderedDescending) {
                return true;
            }
        }
        return false;
    }
}
