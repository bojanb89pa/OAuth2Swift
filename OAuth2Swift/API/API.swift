//
//  API.swift
//  OAuth2Swift
//
//  Created by Bojan Bogojevic on 8/15/18.
//  Copyright © 2018 Gecko Solutions. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class API: NSObject {
    
    static let session: Session = {
        let configuration = URLSessionConfiguration.default
//        configuration.httpAdditionalHeaders = Session.default
        
        return Session(configuration: configuration, interceptor: OAuth2Handler())
    }()
    
    // MARK: - Requests
    
    static public func request(_ urlRequest: URLRequestConvertible, viewController: UIViewController? = nil) -> DataRequest {
        
        return session.request(urlRequest).validate().debugLog().responseData { response in
            switch response.result {
            case .success:
                print("Validation Successful")
            case .failure:
                do {
                    let apiErrorDict = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                    
                    
                    
                    // handling general errors
                    let apiError = ApiError()
                    if let code = apiErrorDict["code"] as? Int {
                        print("Error code: \(code)")
                        apiError.code = code
                    }
                    if let error = apiErrorDict["error"] as? String {
                        print("Received error: \(error)")
                        apiError.error = error
                    }
                    
                    if let vc = viewController {
                        showError(vc, apiError.localizedError)
                    }
                    
                } catch let error as NSError {
                    print(error)
                    if let vc = viewController {
                        showError(vc)
                    }
                }
            }
        }
    }
    
    // MARK: - Messages
    
    static public func showError(_ viewController: UIViewController, _ localizedError : String? = nil) {
        var message = NSLocalizedString("error.DEFAULT_ERROR", value: "Error occurred!", comment: "DEFAULT_ERROR")
        if let locError = localizedError {
            message = locError
        }
        viewController.showOKAlert(title: "Error", message: message)
    }
}
