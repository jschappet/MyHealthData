//
//  HeartRate.swift
//  MyHealthData
//
//  Created by Schappet, James C on 6/6/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import SwiftyJSON

class HeartRate {
    
    
    var heartRateId: Int
    var measureDate: Date
    var value: String
    
    
    var person: String
    
    
    init() {
        self.person = ""
        self.value = ""
        self.measureDate = Date()
        self.heartRateId = -99
    }
    
    
    
    func json() -> [String : AnyObject] {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let parameters: [String: AnyObject] = [
            "personName" : self.person as AnyObject,
            "person" : 2 as AnyObject,
            "value" : self.value as AnyObject,
            
            "measureDate": dateFormatter.string(from: self.measureDate) as AnyObject
            
        ]
        return parameters
    }
    
    init(jsonData: JSON) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        //print(jsonData)
        
        self.person = jsonData["personName"].stringValue
        
        self.value = jsonData["value"].stringValue
        
        let dateString = jsonData["measureDate"].stringValue
        
        if let date =  dateFormatter.date( from: dateString ) {
            self.measureDate = date
        } else {
            print("Date: \(dateString) did not parse")
            self.measureDate = Date()
        }
        
        self.heartRateId = jsonData["heartRateId"].intValue
        
    }
    
}
