//
//  AlertHelper.swift
//  Minhas viagens
//
//  Created by Gilberto Silva on 15/02/21.
//

import Foundation
import UIKit

struct AlertHelper {
    static let shared = AlertHelper()
    private init() { }
    
    func showMessage(viewController:UIViewController, message: String, handler: ((UIAlertAction) -> Void)? = nil){
        let alertViewController = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: handler)
        alertViewController.addAction(okAction)
        viewController.present(alertViewController, animated: true, completion: nil)
    }
    
    func showConfirmationMessage(viewController:UIViewController,
                                 message: String,
                                 positiveHandler: ((UIAlertAction) -> Void)? = nil,
                                 negativeHandler: ((UIAlertAction) -> Void)? = nil){
        let alertViewController = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: positiveHandler)
        let noAction = UIAlertAction(title: "No", style: .default, handler: negativeHandler)
        alertViewController.addAction(yesAction)
        alertViewController.addAction(noAction)
        viewController.present(alertViewController, animated: true, completion: nil)
    }
    
}
