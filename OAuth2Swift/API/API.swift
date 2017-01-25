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
    
    static public func request(_ urlRequest: URLRequestConvertible, viewController: ViewController? = nil) -> DataRequest {
        
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
                    if let code = apiErrorDict["code"] as? Int {
                        print("Error code: \(code)")
                    }
                    if let error = apiErrorDict["error"] as? String {
                        print("Received error: \(error)")
                        
                        if let vc = viewController {
                            let alertController = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                                (result : UIAlertAction) -> Void in
                                print("OK")
                            }
                            
                            alertController.addAction(okAction)
                            
                            vc.present(alertController, animated: true, completion: nil)
                        }
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
                
            }
        }
    }
}
