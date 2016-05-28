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
        case (kAuthorizeHealthKitSection,kAuthorizeHealthKitRow+1):
                print("here")
                let json = JSON(["vitalsDate":"2016-06-12T16:00+00:00","systolic":107,"diatolic":77,"comment":"HealthKit","personName":"Schappet, Jimmy"])
                var vitals = [Vitals]()
                let v = Vitals(jsonData: json)
                vitals.append(v)
                postVitals(vitals)
            
            
            
        default:
            break
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    let baseUrl = "http://localhost:8080/rest/vitals"
    
    func postVitals(vitals: [Vitals]) {
        for v in vitals {
           let request =  Alamofire.request(.POST, baseUrl, parameters: v.json(), encoding: .JSON)
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        print(response)
                        print(response.result.value)
                        
                    case .Failure(let error):
                        print (error)
                    }
                    
            }
            debugPrint(request)
            
        }
    }

    
    
}

