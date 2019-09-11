//
//  DebugConfig.swift
//  OAuth2Swift
//
//  Created by Bojan Bogojevic on 8/15/18.
//  Copyright © 2018 Gecko Solutions. All rights reserved.
//

import Alamofire

extension Request {
    public func debugLog(){
        #if DEBUG
            print(debugDescription)
        #endif
    }
}
