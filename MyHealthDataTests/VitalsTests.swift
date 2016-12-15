//
//  VitalsTests.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/24/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import SwiftyJSON

@testable import MyHealthData

class VitalsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    // Tests to confirm that the Weight initializer returns when no name or a negative rating is provided.
    func testWeightInitialization() {
        let json = JSON(["vitalsId":879,"vitalsDate":"2016-04-12T16:00+00:00","systolic":107,"diatolic":77,"pulse":60,"comment":"","personName":"Schappet, Jimmy"])
        
        XCTAssertEqual(879, json["vitalsId"].intValue)
        
        
        // Success case.
        let potentialItem = Vitals(jsonData: json)
        XCTAssertNotNil(potentialItem)
        print(potentialItem.vitalsId)
        let date = potentialItem.vitalsDate
        
        let dateFormatter = DateFormatter()
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateString = dateFormatter.stringFromDate(date)
        
        
        XCTAssertEqual(dateString, "2016-04-12")
        
        
        XCTAssertEqual(potentialItem.diatolic, 77)
        XCTAssertEqual(potentialItem.systolic, 107)
        XCTAssertEqual(potentialItem.pulse, 60)
        
        
        // Failure cases.
        //let noName = Weight(name: "", photo: nil, rating: 0)
        //XCTAssertNil(noName, "Empty name is invalid")
        
        
        //let badRating = Weight(name: "Really bad rating", photo: nil, rating: -1)
        //XCTAssertNil(badRating, "Negative ratings are invalid, be positive")
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
