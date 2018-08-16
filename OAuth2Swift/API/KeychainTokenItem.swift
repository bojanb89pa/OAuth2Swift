//
//  KeychainTokenItem.swift
//  OAuth2Swift
//
//  Created by Bojan Bogojevic on 8/16/18.
//  Copyright © 2018 Gecko Solutions. All rights reserved.
//

import Foundation
import Alamofire


struct KeychainTokenItem {
    // MARK: Types
    
    enum KeychainError: Error {
        case noToken
        case unexpectedTokenData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
    
    // MARK: Properties
    
    let service: String
    
    private(set) var account: String
    
    let accessGroup: String?
    
    // MARK: Intialization
    
    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
    
    
    
    
    // MARK: Keychain access
    
    func readOAuth2Token() throws -> OAuth2Token  {
        /*
         Build a query to find the item that matches the service, account and
         access group.
         */
        var query = KeychainTokenItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noToken }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        // Parse the token json string from the query result.
        guard let existingItem = queryResult as? [String : AnyObject],
            let tokenData = existingItem[kSecValueData as String] as? Data,
            let tokenJSON = String(data: tokenData, encoding: String.Encoding.utf8),
            let oauth2Token = OAuth2Token(JSONString: tokenJSON)
            else {
                throw KeychainError.unexpectedTokenData
        }
        
        return oauth2Token
    }
    
    func saveOAuth2Token(_ oauth2Token: OAuth2Token) throws {
        // Encode the token into an Data object.
        guard let tokenJSON = oauth2Token.toJSONString() else {
            throw KeychainError.unexpectedTokenData
        }
        
        let encodedToken = tokenJSON.data(using: String.Encoding.utf8)!
        
        do {
            // Check for an existing item in the keychain.
            try _ = readOAuth2Token()
            
            // Update the existing item with the new token.
            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedToken as AnyObject?
            
            let query = KeychainTokenItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
        catch KeychainError.noToken {
            /*
             No token was found in the keychain. Create a dictionary to save
             as a new keychain item.
             */
            var newItem = KeychainTokenItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedToken as AnyObject?
            
            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }
    
    
    mutating func renameAccount(_ newAccountName: String) throws {
        // Try to update an existing item with the new account name.
        var attributesToUpdate = [String : AnyObject]()
        attributesToUpdate[kSecAttrAccount as String] = newAccountName as AnyObject?
        
        let query = KeychainTokenItem.keychainQuery(withService: service, account: self.account, accessGroup: accessGroup)
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
        
        self.account = newAccountName
    }
    
    func deleteItem() throws {
        // Delete the existing item from the keychain.
        let query = KeychainTokenItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    
    
    static func tokenItems(forService service: String, accessGroup: String? = nil) throws -> [KeychainTokenItem] {
        // Build a query for all items that match the service and access group.
        var query = KeychainTokenItem.keychainQuery(withService: service, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanFalse
        
        // Fetch matching items from the keychain.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // If no items were found, return an empty array.
        guard status != errSecItemNotFound else { return [] }
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        // Cast the query result to an array of dictionaries.
        guard let resultData = queryResult as? [[String : AnyObject]] else { throw KeychainError.unexpectedItemData }
        
        // Create a `KeychainTokenItem` for each dictionary in the query result.
        var tokenItems = [KeychainTokenItem]()
        for result in resultData {
            guard let account  = result[kSecAttrAccount as String] as? String else { throw KeychainError.unexpectedItemData }
            
            let tokenItem = KeychainTokenItem(service: service, account: account, accessGroup: accessGroup)
            tokenItems.append(tokenItem)
        }
        
        return tokenItems
    }
    
    
    
    // MARK: Convenience
    
    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String : AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
    
}
