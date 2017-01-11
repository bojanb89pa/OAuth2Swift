//
//  ViewController.swift
//  OAuth2Swiftn//
//  Created by Bojan Bogojevic on 11/3/16.
//  Copyright © 2016 Gecko Solutions. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Actions
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        API.request(OAuth2Router.Login(username: "user", password: "password"))
            .responseObject { (response: DataResponse<OAuth2Token>) in
                
                guard let oauth2Token = response.result.value as OAuth2Token? else {
                    print("Invalid information received from the service")
                    return
                }
                
                debugPrint("Access token \(oauth2Token.accessToken!)")
                debugPrint("Refresh token \(oauth2Token.refreshToken!)")
                print("Is token expired: \(oauth2Token.isExpired())")
                
                AuthorizationManager.sharedManager.oauth2Token = oauth2Token
                
                API.request(OAuth2Router.GetUser(username: "test"))
                    .responseObject{ (response :DataResponse<User>) in
                        if response.result.isSuccess {
                            print("User email is: \(response.result.value?.email)")
                        }
                }
                
        }
    }
    
}

