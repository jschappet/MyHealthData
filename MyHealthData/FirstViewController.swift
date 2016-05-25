//
//  FirstViewController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/18/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import UIKit

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
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
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
    
    
    // MARK: - TableView Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Section: \(indexPath.section) Row: \(indexPath.row)" )
        switch (indexPath.section, indexPath.row)
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
        default:
            break
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

