//
//  Router.swift
//  OAuth2Swift
//
//  Created by Bojan Bogojevic on 8/15/18.
//  Copyright © 2018 Gecko Solutions. All rights reserved.
//


import Foundation
import Alamofire
import ObjectMapper

public enum Router: URLRequestConvertible {
    
    static let timeoutInterval = TimeInterval(10 * 1000)        // 10s
    
    /// Reading server URL from Info.plist
    ///
    /// - returns: base server URL
    private var serverUrl: URL {
        get {
            let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist")! as String
            let dict = NSDictionary(contentsOfFile: plistPath)
            #if DEBUG
            let serverUrlKey = "SERVER_URL_DEBUG"
            #else
            let serverUrlKey = "SERVER_URL"
            #endif
            let serverUrlString = dict!.object(forKey: serverUrlKey) as! String
            return (URL(string: serverUrlString))!
        }
    }
    
    // MARK: route names:
    
    case health
    case login(username: String, password: String)
    case refresh()
    case signup(user: User)
    case getUser(username: String)
    
    
    var path: String {
        switch self {
        case .health:
            return "health"
        case .login, .refresh:
            return "oauth/token"
        case .signup:
            return "signup"
        case .getUser:
            return "user"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .health, .getUser:
            return .get
        case .login, .refresh, .signup:
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
        let result: (parameters: [String: Any]?, encoding: ParameterEncoding?, authorization : AuthorizationType) = {
            var params : [String: Any]? = nil
            var encoding : ParameterEncoding? = nil
            var authType : AuthorizationType = .bearer(oauth2Token: AuthManager.oauth2Token)
            
            switch self {
                
            case .health():
                authType = .none
                
            case .login(let username, let password):
                AuthManager.currentUser = username
                params = ["username" : username, "password" : password, "grant_type" : "password"]
                encoding = Alamofire.URLEncoding.queryString
                authType = .basic(username: AuthManager.clientName, password: AuthManager.clientSecret)
                
            case .refresh():
                let refreshToken = AuthManager.oauth2Token?.refreshToken
                params = ["refresh_token" : refreshToken!, "grant_type" : "refresh_token"]
                encoding = Alamofire.URLEncoding.queryString
                authType = .basic(username: AuthManager.clientName, password: AuthManager.clientSecret)
                
            case .signup(let user):
                params = user.toJSON()
                authType = .none
                
            case .getUser(let username):
                params = ["username" : username]
                
            
            }
            
            return (parameters: params, encoding:encoding, authType)
        }()
        
        var urlRequest = URLRequest(url: serverUrl.appendingPathComponent("\(path)"))
        urlRequest.httpMethod = method.rawValue
        
        let authorizationValue : String = result.authorization.authorizationHeader
        if(authorizationValue != "") {
            urlRequest.setValue(authorizationValue, forHTTPHeaderField: AuthManager.HEADER_AUTH)
        }
        
        urlRequest.timeoutInterval = Router.timeoutInterval
        
        return try addParamsToRequest(urlRequest: urlRequest, requestParams: result.parameters,  encoding: result.encoding, method: method)
        
    }
    
    // MARK: adding parameters
    
    private func addParamsToRequest(urlRequest: URLRequest, requestParams : [String: Any]?, encoding: ParameterEncoding?, method: Alamofire.HTTPMethod) throws -> URLRequest {
        if let param = requestParams {
            var urlEncoding = encoding
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
