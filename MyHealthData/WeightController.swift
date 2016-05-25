//
//  WeightController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/23/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class WeightController: UIViewController,  UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: WeightTableView!
    
    override func viewDidLoad() {
        print("starting view did load: WeightController")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fetchWeights(25) { (weights) in
            self.dataSourceArray = weights!.sort({ (w1, w2)-> Bool in
                w1.weightInDate.timeIntervalSinceReferenceDate > w2.weightInDate.timeIntervalSinceReferenceDate
            })
            self.updateView()
            
        }
        
        print("Done view did load: WeightController")
        
    }
    
    
    
    
    var dataSourceArray = [Weight]()
    
    
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     // Most of the time my data source is an array of something...  will replace with the actual name of the data source
     return dataSourceArray.count
     
     }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string!
        
        let cell = tableView.dequeueReusableCellWithIdentifier("weightCellId")! as UITableViewCell
        let row = indexPath.row
         
        let dateFormatter = NSDateFormatter()
         
         
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
         
        let dateString = dateFormatter.stringFromDate(dataSourceArray[row].weightInDate)
        cell.textLabel?.text =  "\(dataSourceArray[row].value)lbs"
        cell.detailTextLabel?.text = dateString
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
             self.tableView.reloadData()
        })
    }
    
    
    // With Alamofire
    //func fetchWeights() {
    func fetchWeights(count: Int, completion: ([Weight]?) -> Void) {
        var weights = [Weight]()
        
        Alamofire.request(.GET, "https://www.schappet.com/automation/rest/weight" , parameters: ["last": count])
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