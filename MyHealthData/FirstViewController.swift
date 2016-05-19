//
//  FirstViewController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/18/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

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
    
}

