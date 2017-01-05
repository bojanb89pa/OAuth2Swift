//
//  RequestParameters.swift
//  OAuth2Swiftn//
//  Created by Bojan Bogojevic on 11/3/16.
//  Copyright © 2016 Gecko Solutions. All rights reserved.
//

import Foundation
import Alamofire

public class RequestParameters {
    
    var parameters : [String: AnyObject]?
    var encoding : ParameterEncoding?
    
    init(parameters: [String: AnyObject]?, encoding: ParameterEncoding? = nil) {
        self.parameters = parameters
        self.encoding = encoding
    }
}
