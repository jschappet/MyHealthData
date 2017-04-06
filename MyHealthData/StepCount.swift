//
//  StepCount.swift
//  MyHealthData
//
//  Created by Schappet, James C on 6/8/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import SwiftyJSON
import HealthKit

struct StepCount: HealthItem {
    
    
    var id: Int
    var uuid: UUID
    var startDate: Date
    var endDate: Date
    var type = "stepcount"

    
    var value: String
    var deviceName: String
    
    var person: String
    var identifier: HKQuantityTypeIdentifier = HKQuantityTypeIdentifier.stepCount
    
    init() {
        self.uuid = UUID.init()
        self.person = ""
        self.value = ""
        self.startDate = Date()
        self.endDate = Date()
        self.id = -99
        self.deviceName = ""
        
    }
    
    init(sample: HKQuantitySample ) {
        let value1 = sample.quantity.doubleValue(for: HKUnit.count())
        self.uuid = sample.uuid
        self.id = -1
        self.startDate = sample.startDate
        self.endDate = sample.endDate
        self.value = "\(value1)"
        self.person=""
        self.deviceName = sample.sourceRevision.source.name
    }
    
    
    func filter (_ sample: HKQuantitySample) -> Bool {
        return sample.sourceRevision.source.name ==  MyCBLService.sharedInstance.getValue(key: "step.count.source")
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
    
    init(data: JSON) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        //print(jsonData)
        self.uuid = UUID.init()
        self.person = data["personName"].stringValue
        
        self.value = data["value"].stringValue
        
        var dateString = data["measureStartDate"].stringValue
        
        if let date =  dateFormatter.date(from: dateString ) {
            self.startDate = date
        } else {
            print("Start Date: \(dateString) did not parse")
            self.startDate = Date()
        }
        
        dateString = data["endDate"].stringValue
        
        if let date =  dateFormatter.date( from: dateString ) {
            self.endDate = date
        } else {
            print("End Date : \(dateString) did not parse")
            self.endDate = Date()
        }
        
        self.id = data["id"].intValue
        self.deviceName = data["deviceName"].stringValue
    }
    
}
