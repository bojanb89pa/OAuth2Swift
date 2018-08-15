//
//  AuthorizationType.swift
//  OAuth2Swift
//
//  Created by Bojan Bogojevic on 8/15/18.
//  Copyright © 2018 Gecko Solutions. All rights reserved.
//

import UIKit


public enum AuthorizationType {
    case none
    case bearer(oauth2Token: OAuth2Token?)
    case basic(username: String, password: String)
    
    
    var authPrefix: String {
        get {
            switch self {
            case .none:
                return ""
            case .bearer:
                return "Bearer"
            case .basic:
                return "Basic"
            }
        }
    }
    
    var authorizationHeader: String {
        get {
            switch self {
            case .none:
                return ""
            case .bearer(let oauth2Token):
                var token = oauth2Token?.accessToken
                if (oauth2Token?.isExpired() == true || token == nil) {
                    token = oauth2Token?.refreshToken
                }
                guard let headerToken = token else {
                    return ""
                }
                return "\(authPrefix) \(headerToken)"
            case .basic(let username, let password):
                let base64str = "\(username):\(password)".toBase64()
                return "\(authPrefix) \(base64str)"
            }
        }
    }
}