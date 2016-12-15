//
//  WelcomeController.swift
//  MyHealthData
//
//  Created by James Schappet on 12/13/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation


class WelcomeController : UIViewController {
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signOut(sender: AnyObject) {
        LoginService.sharedInstance.signOut()
        
        let controllerId = LoginService.sharedInstance.isLoggedIn() ? "Welcome" : "Login";
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: controllerId) as UIViewController
        self.present(initViewController, animated: true, completion: nil)
    }
}
