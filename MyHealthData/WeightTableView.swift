//
//  WeightTableView.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/24/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class WeightTableView: UITableView, UITableViewDataSource, UITableViewDelegate  {
    
    var dataSourceArray = [Weight]()

    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 // This was put in mainly for my own unit testing
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    /*
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Most of the time my data source is an array of something...  will replace with the actual name of the data source
        return 3 // dataSourceArray.count 
        
    }
    */
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string!
        
        let cell = tableView.dequeueReusableCellWithIdentifier("weightCellId")! as UITableViewCell
        /*
        
        let row = indexPath.row
        
        let dateFormatter = NSDateFormatter()
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let dateString = dateFormatter.stringFromDate(dataSourceArray[row].weightInDate)
        */
        cell.textLabel?.text =  "foo" //"\(dataSourceArray[row].value)lbs"
        cell.detailTextLabel?.text = "bar"  //dateString
        // set cell's textLabel.text property
        // set cell's detailTextLabel.text property
        return cell
    }
    
    
    
    // MARK : Get Data
    
    func updateView() {
        for w in dataSourceArray {
            print("\(w.weightInDate) \(w.value)" )
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
           // tableView.reloadData()
        })
    }
    
    
    // With Alamofire
    //func fetchWeights() {
    func fetchWeights(completion: ([Weight]?) -> Void) {
        var weights = [Weight]()
        
        Alamofire.request(.GET, "https://www.schappet.com/automation/rest/weight" , parameters: ["last": "100"])
            .validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        for (_,subJson):(String, JSON) in json {
                            let w = Weight(jsonData: subJson)
                            weights.append(w)
                            //print("JSON: \(index) \(w.person) \(w.weightInDate) \(w.value)")
                        }
                        completion(weights)
                    }
                case .Failure(let error):
                    print(error)
                    completion(nil)
                }
        }
        
        
    }

    
}