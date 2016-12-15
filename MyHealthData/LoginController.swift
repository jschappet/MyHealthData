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
    
    let login_url = "http://www.schappet.com:5984/"
    let checksession_url = "http://www.schappet.com:5984/"
    
    @IBOutlet var username_input: UITextField!
    @IBOutlet var password_input: UITextField!
    @IBOutlet var login_button: UIButton!
    
    var login_session:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
    }
    
    @IBAction func DoLogin(_ sender: AnyObject) {
        
        var username = self.username_input.text
        var password = self.password_input.text
        
        LoginService.sharedInstance.loginWithCompletionHandler(username, password: password) { (error) -> Void in
            
            if ((error) != nil) {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var alert = UIAlertController(title: "Why are you doing this to me?!?", message: error, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let controllerId = LoginService.sharedInstance.isLoggedIn() ? "Welcome" : "Login";
                    
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let initViewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier(controllerId) as UIViewController
                    self.presentViewController(initViewController, animated: true, completion: nil)
                })
            }
        }
    }
    
}
