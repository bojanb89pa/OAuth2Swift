//
//  Authorization.swift
//  OAuth2Swiftn//
//  Created by Bojan Bogojevic on 11/4/16.
//  Copyright © 2016 Gecko Solutions. All rights reserved.
//

import Foundation
import Alamofire

public class AuthorizationManager {
    
    static let sharedManager = AuthorizationManager()
    
    static let AUTH_BASIC = "Basic"
    static let AUTH_BEARER = "Bearer"
    
    static let HEADER_AUTH = "Authorization"
    
    private init() {}
    
    
    /// Reading client name from Info.plist
    ///
    /// - returns: client name for OAuth 2.0 authentication
    private func getClientName () -> String {
        let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist")! as String
        let dict = NSDictionary(contentsOfFile: plistPath)
        
        return dict!.object(forKey: "clientName") as! String
    }
    
    /// Reading client secret from Info.plist
    ///
    /// - returns: client secret for OAuth 2.0 authentication
    private func getClientSecret () -> String {
        let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist")! as String
        let dict = NSDictionary(contentsOfFile: plistPath)
        
        return dict!.object(forKey: "clientSecret") as! String
    }
    
    
    private var _oauth2Token : OAuth2Token?
    
    var oauth2Token : OAuth2Token? {
        get {
            if((_oauth2Token) == nil) {
                let defaults = UserDefaults.standard
                if let jsonString = defaults.string(forKey: "oauth2Token") {
                    _oauth2Token = OAuth2Token(JSONString: jsonString)
                }
                
            }
            
            return _oauth2Token
        }
        set {
            _oauth2Token = newValue
            let defaults = UserDefaults.standard
            let jsonString = _oauth2Token?.toJSONString()
            defaults.set(jsonString, forKey: "oauth2Token")
        }
    }
    
    func getAuthorization(forType: AuthorizationType) -> String {
        var authString : String = ""
        switch (forType) {
        case AuthorizationType.ClientAuthorization:
            authString = getClientAuthorization()
        case AuthorizationType.TokenAuthorization:
            if(oauth2Token?.accessToken != nil && oauth2Token?.refreshToken != nil) {
                authString = getTokenAuthorization()
            }
        default:
            authString = ""
            
        }
        return authString
    }
    
    func getClientAuthorization () -> String {
        let base64str = "\(getClientName()):\(getClientSecret())".toBase64()
        return "\(AuthorizationManager.AUTH_BASIC) \(base64str)"
    }
    
    func getTokenAuthorization () -> String {
        var token = oauth2Token?.accessToken
        if ((oauth2Token?.isExpired())! || token == nil) {
            token = oauth2Token?.refreshToken
        }
        
        return "\(AuthorizationManager.AUTH_BEARER) \(token!)"
    }
}
