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
                    if let code = apiErrorDict["code"] as? Int,
                        let codeMessage = apiErrorDict["codeMessage"] as? String {
                        // handling general errors
//                        let apiError = ApiError(code:code, codeMessage: codeMessage)
                        print("Received error with code: \(code), and code message: \(codeMessage)")
                    }
                } catch let error as NSError {
                    print(error)
                }
                
            }
        }
    }
}
