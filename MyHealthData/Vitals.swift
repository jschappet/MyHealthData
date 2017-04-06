//
//  Vitals.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/24/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Vitals {
    
    
    //{"vitalsId":879,"vitalsDate":"2016-04-12T16:00+00:00","systolic":107,"diatolic":77,"pulse":60,"comment":"","personName":"Schappet, Jimmy"}
    
   
    
    
    var systolic: Int
    var diatolic: Int
    var pulse: Int
    
    
    //private Integer weightId;
    var id : Int
    var uuid : UUID
    //private String value;
    var value : String;
    
    //private Date weightInDate;
    var startDate : Date
    var endDate : Date
    var deviceName : String
    
    //private Person person;
    var person : String
    
    var type : String

    
    
    init() {
        self.id = -99
        self.person = ""
        self.systolic = 0
        self.diatolic = 0
        self.pulse = 0
        self.startDate = Date()
        self.endDate = Date()
        self.type="vitals"
        self.value=""
        self.deviceName=""
        self.uuid = UUID.init()
    }
    
    
   
    func json() -> [String : AnyObject] {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let parameters: [String: AnyObject] = [
            "personName" : self.person as AnyObject,
            "person" : 2 as AnyObject,
            "systolic" : self.systolic as AnyObject,
            "diatolic" : self.diatolic as AnyObject,
            "vitalsDate": dateFormatter.string(from: self.startDate) as AnyObject
            
        ]
        return parameters
    }
    
    init(jsonData: JSON) {
        self.id = jsonData["vitalsId"].intValue
        
        
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        
        self.person = jsonData["personName"].stringValue
        
        self.systolic = jsonData["systolic"].intValue
        self.diatolic = jsonData["diatolic"].intValue
        
        self.pulse = jsonData["pulse"].intValue
        
        let dateString = jsonData["vitalsDate"].stringValue
        
        if let date =  dateFormatter.date( from: dateString ) {
            self.startDate = date
            self.endDate = date
        } else {
            print("Date: \(dateString) did not parse")
            self.startDate = Date()
            self.endDate = Date()
        }
        self.type="vitals"

        self.value=""
        self.deviceName=""
        self.uuid = UUID.init()
        
    }
    
}
