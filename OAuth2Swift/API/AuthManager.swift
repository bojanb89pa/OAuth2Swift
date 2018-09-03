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
    fileprivate static var _currentAccount : String?
    fileprivate static var _oauth2Token : OAuth2Token?
    
    // Keys:
    fileprivate static let KEY_CURRENT_ACCOUNT = "AuthManager.CurrentAccount"
    
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
    
    
    static var currentAccount: String? {           // username or user id
        get {
            if(_currentAccount == nil) {
                _currentAccount = defaults.string(forKey: KEY_CURRENT_ACCOUNT)
            }
            return _currentAccount
        }
        set {
            _currentAccount = newValue
            defaults.set(_currentAccount, forKey: KEY_CURRENT_ACCOUNT)
            
        }
    }
    
    // if we use username for currentAccount and if we would like to rename this user,
    // we should call this method to keep token data for this user
    func updateAccountName(newAccountName: String) {
        if let currentAccount = AuthManager.currentAccount, currentAccount != newAccountName {
            
        } else {
            AuthManager.currentAccount = newAccountName
        }
    }
    
    
    static var oauth2Token : OAuth2Token? {
        get {
            if(_oauth2Token == nil) {
                
                // If an account name has been set, read any existing password from the keychain.
                if let accountName = currentAccount {
                    do {
                        let tokenItem = KeychainTokenItem(service: KeychainConfiguration.serviceName, account: accountName, accessGroup: KeychainConfiguration.accessGroup)
                        _oauth2Token = try tokenItem.readOAuth2Token()
                    }
                    catch {
                        print("Token wasn't read, reason - \(error)")
                    }
                }
            }
            
            return _oauth2Token
        }
        set {
            _oauth2Token = newValue
            
            // Check if we need to update an existing item or create a new one.
            do {
                if let accountName = currentAccount {
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
