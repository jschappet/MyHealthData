//
//  HealthItem.swift
//  MyHealthData
//
//  Created by Schappet, James C on 12/9/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import HealthKit
import SwiftyJSON


protocol HealthItem {
  
 
    var id : Int { get set }
    var uuid : UUID { get set }
    var value : String { get set }
   
    
    var startDate : Date { get set }
    var endDate : Date { get set }
    var deviceName : String { get set }
    
    //private Person person;
    var person : String { get set }
    
    var type : String { get set }
    var identifier:  HKQuantityTypeIdentifier { get set }
    
    func json() -> [String : AnyObject]
    
    init(data: JSON)
    init(sample: HKQuantitySample)
    init()
    
    func filter(_ sample: HKQuantitySample) -> Bool
    
    
    
   /*
    init() {
        self.id = -1
        self.uuid = UUID.init()
        self.value = "-1"
        self.deviceName = ""
        self.endDate = Date()
        self.startDate = Date()
        self.person = ""
        self.type = "undefinded"
        self.identifier = HKQuantityTypeIdentifier.stepCount
    }
    */
    
}
