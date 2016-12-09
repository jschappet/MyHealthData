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
    var id = -1
    var uuid = UUID.init()
    //private String value;
    var value = "";
    
    //private Date weightInDate;
    var startDate = Date()
    var endDate = Date()
    var deviceName = ""
    
    //private Person person;
    var person = ""
}
