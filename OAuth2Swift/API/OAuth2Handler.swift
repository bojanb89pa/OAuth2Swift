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
    private typealias RefreshCompletion = (_ succeeded: Bool) -> Void
    
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
            //get token
        }
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if (urlRequest.url != nil) {
            var urlRequest = urlRequest
            if (urlRequest.allHTTPHeaderFields?.keys.contains(AuthManager.HEADER_AUTH))! {
                let headerAuthorization : String = urlRequest.value(forHTTPHeaderField: AuthManager.HEADER_AUTH)!
                if headerAuthorization.hasPrefix(AuthorizationType.bearer(oauth2Token: nil).authPrefix), let accessToken = AuthManager.oauth2Token?.accessToken, !headerAuthorization.hasSuffix(accessToken){
                    urlRequest.setValue((AuthorizationType.bearer(oauth2Token: AuthManager.oauth2Token).authorizationHeader), forHTTPHeaderField: AuthManager.HEADER_AUTH)
                }
            }
            return urlRequest
        }
        
        return urlRequest
    }
    
    // MARK: - Private - Refresh Tokens
    
    private func refreshTokens(session: Session, completion: @escaping RefreshCompletion) {
        if(AuthManager.oauth2Token?.refreshToken != nil) {
            session.request(Router.refresh).debugLog().responseObject{ (response: DataResponse<OAuth2Token>) in
    
                    let statusCode = response.response?.statusCode
                    print("Status code: \(statusCode!)")
                
                do {
                    let oauth2Token = try response.result.get()
                    AuthManager.oauth2Token = oauth2Token
                    completion(true)
                } catch _ {
                    completion(false)
                }
            }
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                completion(false)
            }
        }
    }
}
