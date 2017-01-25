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
import ObjectMapper

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
            case .failure:
                do {
                    let apiErrorDict = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                    
                    // handling general errors
                    //                        let apiError = ApiError(code:code, error: error)
                    if let error = apiErrorDict["error"] as? String {
                        print("Received error: \(error)")
                    }
                    if let code = apiErrorDict["code"] as? Int {
                        print("Error code: \(code)")
                    }
                } catch let error as NSError {
                    print(error)
                }
                
            }
        }
    }
}
