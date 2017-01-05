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
            
            let statusCode = response.response?.statusCode
            if statusCode != nil {
                print("Status code: \(statusCode)")
            }
            
            XCTAssert(statusCode != nil && statusCode! >= 200 && statusCode! < 300, "Status code wasn't 2xx")
            
            debugPrint(response)
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
                
                let statusCode = response.response?.statusCode
                if statusCode != nil {
                    print("Status code: \(statusCode)")
                }
                
                XCTAssert(statusCode != nil && statusCode! >= 200 && statusCode! < 300, "Status code wasn't 2xx")
                XCTAssertNotNil(response.result.value as OAuth2Token?, "Invalid information received from the service")
                
                let oauth2Token = response.result.value as OAuth2Token?
                
                debugPrint("Access token \(oauth2Token?.accessToken)")
                debugPrint("Refresh token \(oauth2Token?.refreshToken)")
                print("Is token expired: \(oauth2Token?.isExpired())")
                
                AuthorizationManager.sharedManager.oauth2Token = oauth2Token
                
                expectationCheck.fulfill()
                
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
    }
    
    func testAddLevel() {
        
        let expectationCheck = expectation(description: "AddLevel")
        API.request(OAuth2Router.AddLevel(level: Level(name: "test", mapWidth: 100.0, mapHeight: 100.0)))
            .response(completionHandler: { (response) in
                
                XCTAssertNil(response.error, "Error while adding level!")
                
                let statusCode = response.response?.statusCode
                if statusCode != nil {
                    print("Status code: \(statusCode)")
                }
                
                XCTAssert(statusCode != nil && statusCode! >= 200 && statusCode! < 300, "Status code wasn't 2xx")
                
                print("Level added!")
                
                expectationCheck.fulfill()
            })
        
        waitForExpectations(timeout: 30.0, handler: nil)
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
