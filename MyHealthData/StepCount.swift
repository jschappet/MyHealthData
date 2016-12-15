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
    var measureStartDate: Date
    var measureEndDate: Date
    
    var value: String
    
    
    var person: String
    
    
    init() {
        self.person = ""
        self.value = ""
        self.measureStartDate = Date()
        self.measureEndDate = Date()
        self.id = -99
    }
    
    
    
    func json() -> [String : AnyObject] {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let parameters: [String: AnyObject] = [
            "personName" : self.person as AnyObject,
            "person" : 2 as AnyObject,
            "value" : self.value as AnyObject,
            
            "measureStartDate": dateFormatter.string(from: self.measureStartDate) as AnyObject,
            "measureEndDate": dateFormatter.string(from: self.measureEndDate) as AnyObject
            
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
        
        var dateString = jsonData["measureStartDate"].stringValue
        
        if let date =  dateFormatter.date(from: dateString ) {
            self.measureStartDate = date
        } else {
            print("Start Date: \(dateString) did not parse")
            self.measureStartDate = Date()
        }
        
        dateString = jsonData["measureEndDate"].stringValue
        
        if let date =  dateFormatter.date( from: dateString ) {
            self.measureEndDate = date
        } else {
            print("End Date : \(dateString) did not parse")
            self.measureEndDate = Date()
        }
        
        self.id = jsonData["id"].intValue
        
    }
    
}
