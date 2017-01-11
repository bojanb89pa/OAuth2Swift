//
//  Level.swift
//  OAuth2Swiftn//
//  Created by Bojan Bogojevic on 11/4/16.
//  Copyright © 2016 Gecko Solutions. All rights reserved.
//

import Foundation
import ObjectMapper

public class User : BaseModel {
    var username : String?
    var email: String?
    var password: String?
    
    required public init?(map: Map){
        super.init(map: map)
    }
    
    init(username: String?, email: String){
        super.init()!
        self.username = username
        self.email = email
    }
    
    init(username: String?, email: String, password: String){
        super.init()!
        self.username = username
        self.email = email
        self.password = password
    }
    
    public override func mapping(map: Map) {
        username <- map["username"]
        email <- map["email"]
        password <- map["password"]
    }
}
