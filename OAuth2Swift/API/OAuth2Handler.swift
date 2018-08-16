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
    
    // MARK: - RequestRetrier
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        var shouldRetry = false
        
        let session = URLSession.shared
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            if let request = request.request {
                
                if (request.allHTTPHeaderFields?.keys.contains(AuthManager.HEADER_AUTH))! {
                    let headerAuthorization : String = (request.value(forHTTPHeaderField: AuthManager.HEADER_AUTH))!
                    if headerAuthorization.hasPrefix(AuthorizationType.bearer(oauth2Token: nil).authPrefix){
                        self.requestsToRetry.append(completion)
                        shouldRetry = true
                        if !self.isRefreshing {
                            self.refreshTokens { [weak self] succeeded in
                                guard let strongSelf = self else { return }
                                
                                strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                                
                                strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                                strongSelf.requestsToRetry.removeAll()
                            }
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
        if(AuthManager.oauth2Token?.refreshToken != nil) {
            sessionManager.request(Router.refresh).debugLog().responseObject{ [weak self] (response: DataResponse<OAuth2Token>) in
                guard let strongSelf = self else { return }
                
                guard let _ = response.result.value else {
                    //TODO print error message
                    //print("Error while refreshing tokens: \(response.result.error)")
                    completion(false)
                    return
                }
                
                let statusCode = response.response?.statusCode
                print("Status code: \(statusCode!)")
                
                if let oauth2Token = response.result.value {
                    AuthManager.oauth2Token = oauth2Token
                    completion(true)
                } else {
                    completion(false)
                }
                
                strongSelf.isRefreshing = false
            }
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                completion(false)
                self.isRefreshing = false
            }
        }
    }
}
