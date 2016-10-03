//
//  Weight.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/19/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import SwiftyJSON

class Weight {
    
    //private Integer weightId;
    var weightId: Int
    
    //private String value;
    var value: String
    
    //private Date weightInDate;
    var weightInDate: Date
    
    //private Person person;
    var person: String
    
    init(value: String, person: String, weightId: Int, weightInDate: Date) {
        
        // Initialize stored properties.
        self.value = value
        self.person = person
        self.weightId = weightId
        
        self.weightInDate = weightInDate
        
        
    }
    
 
    init(jsonData: JSON) {
        self.person = jsonData["personName"].stringValue
        
        self.value = "\(jsonData["valueFloat"].floatValue)"
        
        let dateString = jsonData["weightInDate"].stringValue
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let date =  dateFormatter.date( from: dateString ) {
             self.weightInDate = date
        } else {
            print("Date: \(dateString) did not parse")
            self.weightInDate = Date()
        }
        
        self.weightId = jsonData["weightId"].intValue
        
    }
    
}
