//
//  FirstViewController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/18/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FirstViewController: UITableViewController {

    
    let kAuthorizeHealthKitSection = 0

    let kAuthorizeHealthKitRow = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    
    
    let healthManager:HealthManager = HealthManager()
    
    func authorizeHealthKit(_ completion: ((_ success:Bool, _ error:NSError?) -> Void)!)
    {
        healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                print("HealthKit authorization received.")
            }
            else
            {
                print("HealthKit authorization denied!")
                if error != nil {
                    print("\(error)")
                }
            }
        }
        
    }
    lazy var database = MyCBLService.sharedInstance.createHealthDataDb()

    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Section: \((indexPath as NSIndexPath).section) Row: \((indexPath as NSIndexPath).row)" )
        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row)
        {
        case (kAuthorizeHealthKitSection,kAuthorizeHealthKitRow):
            authorizeHealthKit { (authorized, error) -> Void in
                // If authorization is received a nil error will be returned.
                if error == nil {
                    print("health auth recieved.")
                } else {
                    print("health auth denied.")
                    print("\(error)")
                }
            }
        case (kAuthorizeHealthKitSection,kAuthorizeHealthKitRow+1):
            print("here")
            LoginService.sharedInstance.signOut()
            
            let controllerId = LoginService.sharedInstance.isLoggedIn() ? "Welcome" : "Login";
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: controllerId) as UIViewController
            self.present(initViewController, animated: true, completion: nil)
            
            
        default:
            break
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func signOut(sender: AnyObject) {

    }


    
    
}

