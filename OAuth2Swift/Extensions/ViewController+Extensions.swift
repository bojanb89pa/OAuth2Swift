//
//  ViewControllerUtils.swift
//  OAuth2Swift
//
//  Created by Bojan Bogojevic on 2/14/17.
//  Copyright © 2017 Gecko Solutions. All rights reserved.
//

import UIKit

extension UIViewController {
    func showOKAlert(title : String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let title = NSLocalizedString("popup.button.ok", value: "OK", comment: "OK")
        
        let okAction = UIAlertAction(title: title, style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
