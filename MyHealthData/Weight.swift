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

struct Weight : HealthItem{
    
    var id: Int
    var uuid: UUID
    var value: String
    
    var startDate: Date
    var endDate: Date
    var deviceName: String
    
    var person: String
    var type = "weight"
    
    
    var identifier: HKQuantityTypeIdentifier = HKQuantityTypeIdentifier.bodyMass
    
    
    init(value: String, person: String, weightId: Int, weightInDate: Date) {
        
        self.value = value
        self.person = person
        self.id = weightId
        
        self.startDate = weightInDate
        self.endDate = weightInDate
        
        self.uuid = UUID.init()
        self.deviceName = ""
        
        
    }
    
    
    init() {
        
        self.value = ""
        self.person = ""
        self.id = -1
        
        self.startDate = Date()
        self.endDate =  Date()
        
        self.uuid = UUID.init()
        self.deviceName = ""
        
        
    }
    
    
    func json() -> [String : AnyObject] {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let parameters: [String: AnyObject] = [
            "personName" : self.person as AnyObject,
            "person" : 2 as AnyObject,
            "value" : self.value as AnyObject,
            //"uuid" : self.uuid as AnyObject,
            "startDate": dateFormatter.string(from: self.startDate) as AnyObject,
            "endDate": dateFormatter.string(from: self.endDate) as AnyObject,
            "deviceName": self.deviceName as AnyObject
            
        ]
        return parameters
    }
    
    func filter (_ sample: HKQuantitySample) -> Bool {
        return true
    }
    
    init(sample: HKQuantitySample) {
        
        self.uuid = sample.uuid
        self.person = ""
        self.startDate = sample.startDate
        self.endDate = sample.endDate
        
        self.deviceName = sample.sourceRevision.source.name
        let value1 = sample.quantity.doubleValue(for: HKUnit.pound())
        self.value = "\(value1)"
        self.id = -1

    }
 
    init(data: JSON) {
        
        self.person = data["personName"].stringValue
        self.uuid = UUID.init()
        self.deviceName = ""
        
        self.value = "\(data["valueFloat"].floatValue)"
        
        let dateString = data["weightInDate"].stringValue
        
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
        
        self.id = data["weightId"].intValue
        
    }
    
}
