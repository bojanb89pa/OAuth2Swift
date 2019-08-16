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
    
    @IBAction func checkServer(_ sender: Any) {
        API.request(Router.health, viewController:self)
            .responseObject { (response :DataResponse<Health>) in
                do {
                    if let status = try response.result.get().status {
                        self.showMessage("Status: \(status)")
                    }
                } catch _ {
                    self.showMessage("Error occured")
                }
        }
    }
    
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        self.login("user", "password")
    }
    
    @IBAction func logout(_ sender: Any) {
        AuthManager.oauth2Token = nil
        AuthManager.currentAccount = nil
        self.showMessage("Access token removed!")
    }
    
    @IBAction func register(_ sender: Any) {
        
        let username = "test"
        let email = "test@mailinator.com"
        let password = "test123"
        
        API.request(Router.signup(user: User(username: username, email: email, password: password)), viewController: self)
            .responseData {response in
                do {
                    let _ = try response.result.get()
                    self.login(username, password)
                } catch _ {
                    API.showError(self)
                }
        }
    
    }

    @IBAction func checkUser(_ sender: Any) {
        
        let username = "test"
        
        API.request(Router.getUser(username: username), viewController:self)
            .responseObject { (response: DataResponse<User>) in
                do {
                    let user = try response.result.get()
                    if let username = user.username,
                        let email = user.email {
                        self.showMessage("Username: \(username)\nemail: \(email)")
                    }
                } catch _ {
                    API.showError(self)
                }
        }
    }
    
    func login(_ username: String, _ password: String) {
        API.request(Router.login(username: username, password: password), viewController:self)
            .responseObject { (response: DataResponse<OAuth2Token>) in
                do {
                    let oauth2Token = try response.result.get()
                    
                    if let accessToken = oauth2Token.accessToken {
                        print("Access token \(accessToken)")
                        self.showMessage("Access token: \(accessToken)")
                    }
                    if let refreshToken = oauth2Token.refreshToken {
                        print("Refresh token \(refreshToken)")
                    }
                    
                    print("Is token expired: \(oauth2Token.isExpired())")
                    
                    AuthManager.oauth2Token = oauth2Token
                } catch _ {
                    print("Invalid information received from the service")
                    return
                }
        }
    }
    
    // MARK: Messages
    func showMessage(_ message: String) {
        
        let alertController = UIAlertController(title: "Message", message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

