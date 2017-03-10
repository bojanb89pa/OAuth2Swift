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
    
    // MARK: - Requests
    
    static public func request(_ urlRequest: URLRequestConvertible, viewController: UIViewController? = nil) -> DataRequest {
        
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
    
    // MARK: - Upload multipart form data with body parts
    
    
    typealias UploadCompletion = (_ uploadRequest: UploadRequest) -> Void
    
    class public func upload( _ urlRequest: URLRequestConvertible, uploadFileUrl : URL, bodyPartParams: [String: Any]? = nil, viewController: UIViewController? = nil, completionHandler: @escaping UploadCompletion) {
        
        sessionManager.retrier = OAuth2Handler()
        sessionManager.adapter = OAuth2Handler()
        
        sessionManager.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(uploadFileUrl, withName: "file")
            
            if let partParameters = bodyPartParams {
                for (key, value) in partParameters {
                    if let valueData = "\(value)".data(using: .utf8) {
                        multipartFormData.append(valueData, withName: key)
                    }
                }
            }
        }, with: urlRequest) { (encodingResult) in
            switch encodingResult {
                
            case .success(let upload, _, _):
                upload.validate()
                completionHandler(upload)
            case .failure(let encodingError):
                print(encodingError)
                if let vc = viewController {
                    showError(vc)
                }
            }
        }
    }
    
    
    
    // MARK: - Messages
    
    static private func showError(_ viewController: UIViewController, _ localizedError : String? = nil) {
        var message = NSLocalizedString("error.DEFAULT_ERROR", value: "Error occurred!", comment: "DEFAULT_ERROR")
        if let locError = localizedError {
            message = locError
        }
        viewController.showOKAlert(title: "Error", message: message)
    }
}
