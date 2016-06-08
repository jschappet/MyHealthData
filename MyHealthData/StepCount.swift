//
//  StepCount.swift
//  MyHealthData
//
//  Created by Schappet, James C on 6/8/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import SwiftyJSON

class StepCount {
    
    
    var id: Int
    var measureStartDate: NSDate
    var measureEndDate: NSDate
    
    var value: String
    
    
    var person: String
    
    
    init() {
        self.person = ""
        self.value = ""
        self.measureStartDate = NSDate()
        self.measureEndDate = NSDate()
        self.id = -99
    }
    
    
    
    func json() -> [String : AnyObject] {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let parameters: [String: AnyObject] = [
            "personName" : self.person,
            "person" : 2,
            "value" : self.value,
            
            "measureStartDate": dateFormatter.stringFromDate(self.measureStartDate),
            "measureEndDate": dateFormatter.stringFromDate(self.measureEndDate)
            
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
        
        var dateString = jsonData["measureStartDate"].stringValue
        
        if let date =  dateFormatter.dateFromString( dateString ) {
            self.measureStartDate = date
        } else {
            print("Start Date: \(dateString) did not parse")
            self.measureStartDate = NSDate()
        }
        
        dateString = jsonData["measureEndDate"].stringValue
        
        if let date =  dateFormatter.dateFromString( dateString ) {
            self.measureEndDate = date
        } else {
            print("End Date : \(dateString) did not parse")
            self.measureEndDate = NSDate()
        }
        
        self.id = jsonData["id"].intValue
        
    }
    
}
