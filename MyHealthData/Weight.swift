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

class Weight {
    
    //private Integer weightId;
    var weightId: Int
    var uuid: UUID
    //private String value;
    var value: String
    
    //private Date weightInDate;
    var weightInDate: Date
    var deviceName: String
    
    //private Person person;
    var person: String
    
    init(value: String, person: String, weightId: Int, weightInDate: Date) {
        
        // Initialize stored properties.
        self.value = value
        self.person = person
        self.weightId = weightId
        
        self.weightInDate = weightInDate
        self.uuid = UUID.init()
        self.deviceName = ""
        
    }
    
    
    init(hkSample: HKQuantitySample) {
        self.uuid = hkSample.uuid
        self.person = ""
        self.weightInDate = hkSample.startDate
        if let deviceName = hkSample.device?.name {
            self.deviceName = deviceName
        } else {
            self.deviceName = ""
        }
        
        let value1 = hkSample.quantity.doubleValue(for: HKUnit.pound())
        self.value = "\(value1)"
        self.weightId = -1

    }
 
    init(jsonData: JSON) {
        self.person = jsonData["personName"].stringValue
        self.uuid = UUID.init()
        self.deviceName = ""
        
        self.value = "\(jsonData["valueFloat"].floatValue)"
        
        let dateString = jsonData["weightInDate"].stringValue
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let date =  dateFormatter.date( from: dateString ) {
             self.weightInDate = date
        } else {
            print("Date: \(dateString) did not parse")
            self.weightInDate = Date()
        }
        
        self.weightId = jsonData["weightId"].intValue
        
    }
    
}
