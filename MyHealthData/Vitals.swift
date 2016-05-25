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
    
    
    
    
    init(jsonData: JSON) {
        self.person = jsonData["personName"].stringValue
        
        self.systolic = jsonData["systolic"].intValue
        self.diatolic = jsonData["diatolic"].intValue
        
        self.pulse = jsonData["pulse"].intValue
        
        let dateString = jsonData["vitalsDate"].stringValue
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZZZ"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        if let date =  dateFormatter.dateFromString( dateString ) {
            self.vitalsDate = date
        } else {
            print("Date: \(dateString) did not parse")
            self.vitalsDate = NSDate()
        }
        
        self.vitalsId = jsonData["vitalsId"].intValue
        
    }
    
}
