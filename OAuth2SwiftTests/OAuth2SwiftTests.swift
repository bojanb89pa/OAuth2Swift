//
//  OAuth2SwiftTests.swift
//  OAuth2SwiftTests
//
//  Created by Bojan Bogojevic on 1/5/17.
//  Copyright © 2017 Gecko Solutions. All rights reserved.
//

import XCTest
@testable import OAuth2Swift
@testable import Alamofire
@testable import AlamofireObjectMapper

class OAuth2SwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testServer() {
        
        let expectationCheck = expectation(description: "Health")
        
        API.request(OAuth2Router.Health()).responseObject { (response : DataResponse<Health>) in
            
            XCTAssert(response.result.isSuccess, "Failed to complete login request!")
            
            var statusCode200 = false
            if let statusCode = response.response?.statusCode {
                statusCode200 = statusCode >= 200 && statusCode < 300
                print("Status code: \(statusCode)")
            }
            
            XCTAssert(statusCode200, "Status code wasn't 2xx")
            
            print(response)
            expectationCheck.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testLogout() {
        AuthorizationManager.sharedManager.oauth2Token = nil
    }
    
    
    func testLogin() {
        let expectationCheck = expectation(description: "Login")
        
        API.request(OAuth2Router.Login(username: "user", password: "password"))
            .responseObject { (response: DataResponse<OAuth2Token>) in
                
                XCTAssert(response.result.isSuccess, "Failed to complete login request!")
                
                var statusCode200 = false
                if let statusCode = response.response?.statusCode {
                    statusCode200 = statusCode >= 200 && statusCode < 300
                    print("Status code: \(statusCode)")
                }
                
                XCTAssert(statusCode200, "Status code wasn't 2xx")
                
                XCTAssertNotNil(response.result.value as OAuth2Token?, "Invalid information received from the service")
                
                let oauth2Token = response.result.value as OAuth2Token?
                
                
                if let accessToken = oauth2Token?.accessToken {
                    print("Access token \(accessToken)")
                }
                if let refreshToken = oauth2Token?.accessToken {
                    print("Refresh token \(refreshToken)")
                }
                
                print("Is token expired: \(oauth2Token?.isExpired())")
                
                AuthorizationManager.sharedManager.oauth2Token = oauth2Token
                
                expectationCheck.fulfill()
                
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
    }
    
    func testRegistration() {
        
        let username = "test"
        let email = "test@mailinator.com"
        let password = "test123"
        
        let expectationCheck = expectation(description: "Registration")
        API.request(OAuth2Router.Signup(user: User(username: username, email: email, password: password)))
            .response(completionHandler: { (response) in
                
                XCTAssertNil(response.error, "Error while adding user!")
                
                var statusCode200 = false
                if let statusCode = response.response?.statusCode {
                    statusCode200 = statusCode >= 200 && statusCode < 300
                    print("Status code: \(statusCode)")
                }
                
                XCTAssert(statusCode200, "Status code wasn't 2xx")
                
                if statusCode200 {
                    print("User added!")
                    
                    API.request(OAuth2Router.Login(username: username, password: password))
                        .responseObject { (response: DataResponse<OAuth2Token>) in
                            
                            XCTAssert(response.result.isSuccess, "Failed to complete login request!")
                            
                            var statusCode200 = false
                            if let statusCode = response.response?.statusCode {
                                statusCode200 = statusCode >= 200 && statusCode < 300
                                print("Status code: \(statusCode)")
                            }
                            
                            XCTAssert(statusCode200, "Status code wasn't 2xx")
                            
                            XCTAssertNotNil(response.result.value as OAuth2Token?, "Invalid information received from the service")
                            
                            let oauth2Token = response.result.value as OAuth2Token?
                            
                            if let accessToken = oauth2Token?.accessToken {
                                print("Access token \(accessToken)")
                            }
                            if let refreshToken = oauth2Token?.accessToken {
                                print("Refresh token \(refreshToken)")
                            }
                            
                            print("Is token expired: \(oauth2Token?.isExpired())")
                            
                            AuthorizationManager.sharedManager.oauth2Token = oauth2Token
                            
                            expectationCheck.fulfill()
                            
                    }
                    
                }
            })
        
        waitForExpectations(timeout: 30.0, handler: nil)
    }
    
    func testCheckUser() {
        
        let username = "test"
        let expectationCheck = expectation(description: "Check user")
        
        API.request(OAuth2Router.GetUser(username: username))
            .responseObject { (response: DataResponse<User>) in
                
                XCTAssert(response.result.isSuccess, "Failed to complete get user request!")
                
                var statusCode200 = false
                if let statusCode = response.response?.statusCode {
                    statusCode200 = statusCode >= 200 && statusCode < 300
                    print("Status code: \(statusCode)")
                }
                
                XCTAssert(statusCode200, "Status code wasn't 2xx")
                XCTAssertNotNil(response.result.value as User?, "Invalid information received from the service")
                
                let user = response.result.value as User?
                
                if let username = user?.username {
                    print("Username: \(username)")
                }
                
                if let email = user?.email {
                    print("Email: \(email)")
                }
                
                
                expectationCheck.fulfill()
                
        }
        
        waitForExpectations(timeout: 30.0, handler: nil)
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
