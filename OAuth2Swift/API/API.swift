//
//  API.swift
//  OAuth2Swift
//
//  Created by Bojan Bogojevic on 11/7/16.
//  Copyright © 2016 Gecko Solutions. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class API: NSObject {
    
    static let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
    
    static public func request(_ urlRequest: URLRequestConvertible) -> DataRequest {
        
        sessionManager.retrier = OAuth2Handler()
        sessionManager.adapter = OAuth2Handler()
        return sessionManager.request(urlRequest).validate().responseData { response in
            switch response.result {
            case .success:
                print("Validation Successful")
            case .failure(let error):
                // handling general errors
                print(error)
            }
        }
    }
}
