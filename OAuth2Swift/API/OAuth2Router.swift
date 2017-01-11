//
//  OAuth2Router.swift
//  OAuth2Swiftn//
//  Created by Bojan Bogojevic on 11/3/16.
//  Copyright © 2016 Gecko Solutions. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

public enum OAuth2Router: URLRequestConvertible {
    
    static let timeoutInterval = TimeInterval(10 * 1000)        // 10s
    
    /// Reading server URL from Info.plist
    ///
    /// - returns: base server URL
    private func getServerUrl () -> String {
        let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist")! as String
        let dict = NSDictionary(contentsOfFile: plistPath)
        #if DEBUG
            let serverUrlKey = "SERVER_URL_DEBUG"
        #else
            let serverUrlKey = "SERVER_URL"
        #endif
        return dict!.object(forKey: serverUrlKey) as! String
    }
    
    // MARK: route names:
    
    case Health()
    case Login(username: String, password: String)
    case Refresh()
    case Signup(user: User)
    case GetUser(username: String)
    
    var path: String {
        switch self {
        case .Health:
            return "/health"
        case .Login, .Refresh:
            return "/oauth/token"
        case .Signup:
            return "/signup"
        case .GetUser:
            return "/user"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .Health, .GetUser:
            return .get
        case .Login, .Refresh, .Signup:
            return .post
        }
    }
    
    // MARK: request handler
    
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
    ///
    /// - returns: A URL request.
    public func asURLRequest() throws -> URLRequest {
        let result: (parameters: RequestParameters?, authorization : AuthorizationType) = {
            var params : [String: Any]? = nil
            var encoding : ParameterEncoding? = nil
            var authType : AuthorizationType? = AuthorizationType.TokenAuthorization
            
            switch self {
                
            case .Health():
                authType = AuthorizationType.NoAuthorization
                
            case .Login(let username, let password):
                params = ["username" : username, "password" : password, "grant_type" : "password"]
                encoding = Alamofire.URLEncoding.queryString
                authType = AuthorizationType.ClientAuthorization
                
            case .Refresh():
                let refreshToken = AuthorizationManager.sharedManager.oauth2Token?.refreshToken
                params = ["refresh_token" : refreshToken!, "grant_type" : "refresh_token"]
                encoding = Alamofire.URLEncoding.queryString
                authType = AuthorizationType.ClientAuthorization
                
            case .Signup(let user):
                params = user.toDict()
                authType = AuthorizationType.NoAuthorization
                
            case .GetUser(let username):
                params = ["username" : username]
                
            }
            
            return (RequestParameters(parameters: params, encoding:encoding), authType!)
        }()
        
        
        let url = URL(string: getServerUrl())!
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        let authorizationValue : String = AuthorizationManager.sharedManager.getAuthorization(forType: result.authorization)
        if(authorizationValue != "") {
            urlRequest.setValue(authorizationValue, forHTTPHeaderField: AuthorizationManager.HEADER_AUTH)
        }
        
        urlRequest.timeoutInterval = OAuth2Router.timeoutInterval
        
        return try addParamsToRequest(urlRequest: urlRequest, requestParams: result.parameters, method: method)
        
    }
    
    
    // MARK: adding parameters
    
    private func addParamsToRequest(urlRequest: URLRequest, requestParams : RequestParameters?, method: Alamofire.HTTPMethod) throws -> URLRequest {
        if let param = requestParams?.parameters {
            var urlEncoding = requestParams?.encoding
            if urlEncoding == nil {
                switch method {
                case .get, .delete:
                    urlEncoding = Alamofire.URLEncoding.queryString
                default:
                    urlEncoding = Alamofire.JSONEncoding.default
                }
            }
            return try urlEncoding!.encode(urlRequest, with: param)
        } else {
            return urlRequest;
        }
    }
    
}


