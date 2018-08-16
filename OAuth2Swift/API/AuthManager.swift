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
    
    
    // MARK: - Private properties
    // User defaults
    fileprivate static let defaults = UserDefaults.standard
    
    // Cache properties
    fileprivate static var _currentUser : String?
    fileprivate static var _oauth2Token : OAuth2Token?
    
    // Keys:
    fileprivate static let KEY_CURRENT_USER = "AuthManager.CurrentUser"
    
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
    
    
    static var currentUser: String? {           // username or user id
        get {
            if(_currentUser == nil) {
                _currentUser = defaults.string(forKey: KEY_CURRENT_USER)
            }
            return _currentUser
        }
        set {
            _currentUser = newValue
            defaults.set(_currentUser, forKey: KEY_CURRENT_USER)
            
        }
    }
    
    
    static var oauth2Token : OAuth2Token? {
        get {
            if(_oauth2Token == nil) {
                
                // If an account name has been set, read any existing password from the keychain.
                if let accountName = currentUser {
                    do {
                        let passwordItem = KeychainTokenItem(service: KeychainConfiguration.serviceName, account: accountName, accessGroup: KeychainConfiguration.accessGroup)
                        
                        currentUser = passwordItem.account
                        _oauth2Token = try passwordItem.readOAuth2Token()
                    }
                    catch {
                        fatalError("Error reading password from keychain - \(error)")
                    }
                }
            }
            
            return _oauth2Token
        }
        set {
            _oauth2Token = newValue
            
            // Check if we need to update an existing item or create a new one.
            do {
                if let accountName = currentUser {
                    // Create a keychain item with the original account name.
                    let tokenItem = KeychainTokenItem(service: KeychainConfiguration.serviceName, account: accountName, accessGroup: KeychainConfiguration.accessGroup)
                    
                    if let oauth2Token = _oauth2Token {
                        // Save the oauth2token.
                        try tokenItem.saveOAuth2Token(oauth2Token)
                    } else {
                        try tokenItem.deleteItem()
                    }
                }
            }
            catch {
                fatalError("Error updating keychain - \(error)")
            }
            
        }
    }

}
