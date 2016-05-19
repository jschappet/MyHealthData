//
//  Weight.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/19/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit
import HealthKit


class Weight1 {
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    var startDate: NSDate
    var endDate: NSDate?
    //var srcDevice?: String
    
    var value: Float
    
    init?(sample: HKSample) {
        self.startDate = sample.startDate
        self.endDate = sample.endDate
       // self.srcDevice = sample.device?.name
        
        self.value = 1.1
        
        self.name = ""
        self.photo = nil
        self.rating = 5
        
        if name.isEmpty || rating < 0 {
            return nil
        }
    }
    
    init?(name: String, photo: UIImage?, rating: Int) {
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating
        
        self.startDate = NSDate()
        self.value = 1.1
        
        self.endDate = NSDate()
        
        
        if name.isEmpty || rating < 0 {
            return nil
        }
    }
    
}