//
//  HeartRate.swift
//  MyHealthData
//
//  Created by Schappet, James C on 6/6/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import SwiftyJSON
import HealthKit
struct HeartRate : HealthItem {
    
    
    var id: Int
    var uuid: UUID
    var startDate: Date
    var endDate: Date
    var type = "heartrate"
    
    
    var value: String
    var deviceName: String
    
    var person: String
    var identifier: HKQuantityTypeIdentifier = HKQuantityTypeIdentifier.heartRate
    
  /*
    var id: Int
    var startDate: Date
    var endDate: Date
    var value: String
    var uuid: UUID
    var deviceName : String
    var person: String
    */
    
    init() {

        self.person = ""
        self.value = ""
        self.startDate = Date()
        self.endDate = Date()
        self.id = -99
        self.uuid = UUID.init()
        self.deviceName = ""
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
        let value1 =  sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        
        self.value = "\(value1)"
        self.id = -1
        
    }
    
    
    func json() -> [String : AnyObject] {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let parameters: [String: AnyObject] = [
            "personName" : self.person as AnyObject,
            "person" : 2 as AnyObject,
            "value" : self.value as AnyObject,
            "uuid" : self.uuid as AnyObject,
            "startDate": dateFormatter.string(from: self.startDate) as AnyObject,
            "endDate": dateFormatter.string(from: self.endDate) as AnyObject
            
        ]
        return parameters
    }
    
    init(data: JSON) {
        
        let dateFormatter = DateFormatter()
        self.uuid = UUID.init()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        //print(jsonData)
        
        self.person = data["personName"].stringValue
        
        self.value = data["value"].stringValue
        
        let dateString = data["measureDate"].stringValue
        
        if let date =  dateFormatter.date( from: dateString ) {
            self.startDate = date
            self.endDate = date
        } else {
            print("Date: \(dateString) did not parse")
            self.endDate = Date()
            self.startDate = Date()
        }
        
        self.id = data["id"].intValue
        self.deviceName = data["deviceName"].stringValue;
    }
    
}
