//
//  Weight.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/19/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import SwiftyJSON
import HealthKit

class Weight : HealthItem{
    
      init(value: String, person: String, weightId: Int, weightInDate: Date) {
        super.init()
        // Initialize stored properties.
        self.value = value
        self.person = person
        self.id = weightId
        
        self.startDate = weightInDate
        self.endDate = weightInDate
        
        self.uuid = UUID.init()
        self.deviceName = ""
        
    }
    
    
    init(hkSample: HKQuantitySample) {
        super.init()
        self.uuid = hkSample.uuid
        self.person = ""
        self.startDate = hkSample.startDate
        self.endDate = hkSample.endDate
        
        self.deviceName = hkSample.sourceRevision.source.name
        let value1 = hkSample.quantity.doubleValue(for: HKUnit.pound())
        self.value = "\(value1)"
        self.id = -1

    }
 
    init(jsonData: JSON) {
        super.init()
        self.person = jsonData["personName"].stringValue
        self.uuid = UUID.init()
        self.deviceName = ""
        
        self.value = "\(jsonData["valueFloat"].floatValue)"
        
        let dateString = jsonData["weightInDate"].stringValue
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let date =  dateFormatter.date( from: dateString ) {
             self.startDate = date
            self.endDate = date
            
        } else {
            print("Date: \(dateString) did not parse")
            self.startDate = Date()
            self.endDate = Date()
        }
        
        self.id = jsonData["weightId"].intValue
        
    }
    
}
