//
//  OAuth2Retrier.swift
//  OAuth2Swiftn//
//  Created by Bojan Bogojevic on 1/4/17.
//  Copyright © 2017 Gecko Solutions. All rights reserved.
//

import UIKit
import Alamofire

class OAuth2Handler: RequestRetrier, RequestAdapter {
    private typealias RefreshCompletion = (_ succeeded: Bool) -> Void
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
    
    private let lock = NSLock()
    
    var isRefreshing = false
    
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // MARK: - RequestAdapter
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if (urlRequest.url != nil) {
            var urlRequest = urlRequest
            if (urlRequest.allHTTPHeaderFields?.keys.contains(AuthorizationManager.HEADER_AUTH))! {
                let headerAuthorization : String = urlRequest.value(forHTTPHeaderField: AuthorizationManager.HEADER_AUTH)!
                if headerAuthorization.hasPrefix(AuthorizationManager.AUTH_BEARER), !headerAuthorization.hasSuffix((AuthorizationManager.sharedManager.oauth2Token?.accessToken)!){
                    urlRequest.setValue((AuthorizationManager.sharedManager.getTokenAuthorization()), forHTTPHeaderField: AuthorizationManager.HEADER_AUTH)
                }
            }
            return urlRequest
        }
        
        return urlRequest
    }
    
    // MARK: - RequestRetrier
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        var shouldRetry = false
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            if (request.request?.allHTTPHeaderFields?.keys.contains(AuthorizationManager.HEADER_AUTH))! {
                let headerAuthorization : String = (request.request?.value(forHTTPHeaderField: AuthorizationManager.HEADER_AUTH))!
                if headerAuthorization.hasPrefix(AuthorizationManager.AUTH_BEARER){
                    requestsToRetry.append(completion)
                    shouldRetry = true
                    if !isRefreshing {
                        refreshTokens { [weak self] succeeded in
                            guard let strongSelf = self else { return }
                            
                            strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                            
                            strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                            strongSelf.requestsToRetry.removeAll()
                        }
                    }
                }
            }
        }
        if !shouldRetry {
            completion(false, 0.0)
        }
    }
    
    // MARK: - Private - Refresh Tokens
    
    private func refreshTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }

        isRefreshing = true
        if(AuthorizationManager.sharedManager.oauth2Token?.refreshToken != nil) {
            sessionManager.request(Router.Refresh()).responseObject{ [weak self] (response:DataResponse<OAuth2Token>) in
                guard let strongSelf = self else { return }
                
                guard response.result.isSuccess else {
                    print("Error while refreshing tokens: \(response.result.error)")
                    return
                }
                
                let statusCode = response.response?.statusCode
                print("Status code: \(statusCode!)")
                
                let oauth2Token = response.result.value as OAuth2Token?
                if let accessToken = oauth2Token?.accessToken {
                    print("Access token \(accessToken)")
                }
                if let refreshToken = oauth2Token?.accessToken {
                    print("Refresh token \(refreshToken)")
                }
                print("Is token expired: \(oauth2Token?.isExpired())")
                
                AuthorizationManager.sharedManager.oauth2Token = oauth2Token
                
                if(oauth2Token?.accessToken != nil) {
                    completion(true)
                } else {
                    completion(false)
                }
                
                strongSelf.isRefreshing = false;
            }
        }
    }
}
