//
//  AuthManager.swift
//  OAuth2Swift
//
//  Created by Bojan Bogojevic on 8/15/18.
//  Copyright © 2018 Gecko Solutions. All rights reserved.
//


import Foundation
import Alamofire

public class AuthManager {
    
    static let shared = AuthManager()
    
    static let HEADER_AUTH = "Authorization"
    
    private init() {}
    
    
    /// Reading client name from Info.plist
    ///
    /// - returns: client name for OAuth 2.0 authentication
    static var clientName: String {
        get {
            let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist")! as String
            let dict = NSDictionary(contentsOfFile: plistPath)
            
            return dict!.object(forKey: "clientName") as! String
        }
    }
    
    /// Reading client secret from Info.plist
    ///
    /// - returns: client secret for OAuth 2.0 authentication
    static var clientSecret: String {
        get {
            let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist")! as String
            let dict = NSDictionary(contentsOfFile: plistPath)
            
            return dict!.object(forKey: "clientSecret") as! String
        }
    }
    
    
    // TODO: Store OAuth2 token in Keychain
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

}