//
//  LoginController.swift
//  MyHealthData
//
//  Created by James Schappet on 12/13/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit

class LoginController: UIViewController {
    
    
    @IBOutlet var username_input: UITextField!
    @IBOutlet var password_input: UITextField!
    @IBOutlet var login_button: UIButton!
    
    var login_session:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
    }
    
    @IBAction func DoLogin(_ sender: AnyObject) {
        
        let username = self.username_input.text
        let password = self.password_input.text
        
        LoginService.sharedInstance.loginWithCompletionHandler(username: username!, password: password!) { (error) -> Void in
            
            if ((error) != nil) {
                
                DispatchQueue.main.async(execute: { () -> Void in
                    let alert = UIAlertController(title: "Why are you doing this to me?!?", message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
                
            } else {
                
                DispatchQueue.main.async(execute: { () -> Void in
                    //let controllerId = LoginService.sharedInstance.isLoggedIn() ? "Welcome" : "Login";
                    MyCBLService.sharedInstance.startReplication()
                    let controllerId = "Welcome"
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let initViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: controllerId) as UIViewController
                    self.present(initViewController, animated: true, completion: nil)
                })
            }
        }
    }
    
}
