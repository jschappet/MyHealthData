//
//  HealthController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 3/31/17.
//  Copyright © 2017 University of Iowa - ICTS. All rights reserved.
//

import Foundation

class HealthController: UIViewController  {
    
    
    //var latestDate : NSDate?
    lazy var database = MyCBLService.sharedInstance.createHealthDataDb()
    
    let healthManager:HealthManager = HealthManager()
    
    
    func fetch(_ completion: () -> Void) {
        preconditionFailure("This method must be overridden")
    }
 
    
    func reloadItems() {
        preconditionFailure("This method must be overridden")
    }
    
    
    func setupViewAndQuery() {
           preconditionFailure("This method must be overridden")
    }
}
