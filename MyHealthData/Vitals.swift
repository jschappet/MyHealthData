//
//  Vitals.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/24/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import SwiftyJSON

class Vitals {
    
    
    //{"vitalsId":879,"vitalsDate":"2016-04-12T16:00+00:00","systolic":107,"diatolic":77,"pulse":60,"comment":"","personName":"Schappet, Jimmy"}
    
   
    
    
    var vitalsId: Int
    var vitalsDate: NSDate
    var systolic: Int
    var diatolic: Int
    var pulse: Int
    var person: String
    
    
    init() {
        self.person = ""
        self.systolic = 0
        self.diatolic = 0
        self.pulse = 0
        self.vitalsDate = NSDate()
        self.vitalsId = -99
    }
    
    
   
    func json() -> [String : AnyObject] {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let parameters: [String: AnyObject] = [
            "personName" : self.person,
            "person" : 2,
            "systolic" : self.systolic,
            "diatolic" : self.diatolic,
            "vitalsDate": dateFormatter.stringFromDate(self.vitalsDate)
            
        ]
        return parameters
    }
    
    init(jsonData: JSON) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZZZ"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        
        self.person = jsonData["personName"].stringValue
        
        self.systolic = jsonData["systolic"].intValue
        self.diatolic = jsonData["diatolic"].intValue
        
        self.pulse = jsonData["pulse"].intValue
        
        let dateString = jsonData["vitalsDate"].stringValue
        
        if let date =  dateFormatter.dateFromString( dateString ) {
            self.vitalsDate = date
        } else {
            print("Date: \(dateString) did not parse")
            self.vitalsDate = NSDate()
        }
        
        self.vitalsId = jsonData["vitalsId"].intValue
        
    }
    
}
