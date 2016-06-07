//
//  HeartRate.swift
//  MyHealthData
//
//  Created by Schappet, James C on 6/6/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation

import Foundation
import SwiftyJSON

class HeartRate {
    
    
    var heartRateId: Int
    var measureDate: NSDate
    var value: String
    
    
    var person: String
    
    
    init() {
        self.person = ""
        self.value = ""
        self.measureDate = NSDate()
        self.heartRateId = -99
    }
    
    
    
    func json() -> [String : AnyObject] {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let parameters: [String: AnyObject] = [
            "personName" : self.person,
            "person" : 2,
            "value" : self.value,
            
            "measureDate": dateFormatter.stringFromDate(self.measureDate)
            
        ]
        return parameters
    }
    
    init(jsonData: JSON) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        //print(jsonData)
        
        self.person = jsonData["personName"].stringValue
        
        self.value = jsonData["value"].stringValue
        
        let dateString = jsonData["measureDate"].stringValue
        
        if let date =  dateFormatter.dateFromString( dateString ) {
            self.measureDate = date
        } else {
            print("Date: \(dateString) did not parse")
            self.measureDate = NSDate()
        }
        
        self.heartRateId = jsonData["heartRateId"].intValue
        
    }
    
}
