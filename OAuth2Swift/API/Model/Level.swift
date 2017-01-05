//
//  Level.swift
//  OAuth2Swiftn//
//  Created by Bojan Bogojevic on 11/4/16.
//  Copyright © 2016 Gecko Solutions. All rights reserved.
//

import Foundation
import ObjectMapper

public class Level : BaseModel {
    var name : String?
    var mapWidth: Double?
    var mapHeight: Double?
    
    required public init?(map: Map){
        super.init(map: map)
    }
    
    init(name: String?, mapWidth: Double, mapHeight: Double){
        super.init()!
        self.name = name
        self.mapWidth = mapWidth
        self.mapHeight = mapHeight
    }
    
    public override func mapping(map: Map) {
        name <- map["name"]
        mapWidth <- map["mapWidth"]
        mapHeight <- map["mapHeight"]
    }
}
