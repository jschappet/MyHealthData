//
//  HealthItem.swift
//  MyHealthData
//
//  Created by Schappet, James C on 12/9/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
class HealthItem {
    
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
        self.id = -1
        self.uuid = UUID.init()
        self.value = "-1"
        self.deviceName = ""
        self.endDate = Date()
        self.startDate = Date()
        self.person = ""
        self.type = "undefinded"
    }
    
    
}
