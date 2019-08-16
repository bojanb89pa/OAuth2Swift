//
//  OAuth2Handler.swift
//  OAuth2Swift
//
//  Created by Bojan Bogojevic on 8/15/18.
//  Copyright © 2018 Gecko Solutions. All rights reserved.
//

import UIKit
import ObjectMapper

import Alamofire
import ObjectMapper

struct OAuth2Handler: RequestInterceptor {
    
    // MARK: - RequestAdapter
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
        var adaptedRequest = urlRequest
        if (adaptedRequest.url != nil) {
            var adaptedRequest = urlRequest
            if (adaptedRequest.allHTTPHeaderFields?.keys.contains(AuthManager.HEADER_AUTH))! {
                let headerAuthorization : String = adaptedRequest.value(forHTTPHeaderField: AuthManager.HEADER_AUTH)!
                if headerAuthorization.hasPrefix(AuthorizationType.bearer(oauth2Token: nil).authPrefix), let accessToken = AuthManager.oauth2Token?.accessToken, !headerAuthorization.hasSuffix(accessToken){
                    adaptedRequest.setValue((AuthorizationType.bearer(oauth2Token: AuthManager.oauth2Token).authorizationHeader), forHTTPHeaderField: AuthManager.HEADER_AUTH)
                }
            }
            completion(.success(adaptedRequest))
        }
        completion(.success(adaptedRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            if(AuthManager.oauth2Token?.refreshToken != nil) {
                session.request(Router.refresh).debugLog().responseObject{ (response: DataResponse<OAuth2Token>) in
                    
                    let statusCode = response.response?.statusCode
                    print("Status code: \(statusCode!)")
                    
                    do {
                        let oauth2Token = try response.result.get()
                        AuthManager.oauth2Token = oauth2Token
                        completion(RetryResult.retry)
                    } catch _ {
                        completion(RetryResult.doNotRetry)
                    }
                }
            } else {
                DispatchQueue.global(qos: .userInitiated).async {
                    completion(RetryResult.doNotRetry)
                }
            }
        }
    }
}
