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
class HeartRate : HealthItem {
    
  /*
    var id: Int
    var startDate: Date
    var endDate: Date
    var value: String
    var uuid: UUID
    var deviceName : String
    var person: String
    */
    
    override init() {
        super.init()

        self.person = ""
        self.value = ""
        self.startDate = Date()
        self.endDate = Date()
        self.id = -99
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
        let value1 =  hkSample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        
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
    
    init(jsonData: JSON) {
        super.init()

        let dateFormatter = DateFormatter()
        self.uuid = UUID.init()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        //print(jsonData)
        
        self.person = jsonData["personName"].stringValue
        
        self.value = jsonData["value"].stringValue
        
        let dateString = jsonData["measureDate"].stringValue
        
        if let date =  dateFormatter.date( from: dateString ) {
            self.startDate = date
            self.endDate = date
        } else {
            print("Date: \(dateString) did not parse")
            self.endDate = Date()
            self.startDate = Date()
        }
        
        self.id = jsonData["id"].intValue
        
    }
    
}
