//
//  VitalsController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/25/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import HealthKit

class VitalsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //var latestDate : NSDate?
    
    let healthManager:HealthManager = HealthManager()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let vitalDateSort = { (v1: Vitals, v2: Vitals) -> Bool in
        return (v1.vitalsDate.timeIntervalSinceReferenceDate > v2.vitalsDate.timeIntervalSinceReferenceDate)
    }
    
    
    override func viewDidLoad() {
        print("starting view did load: VitalsController")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fetchWeights(25) { (items) in
            self.dataSourceArray = items!.sort(self.vitalDateSort)
            
            //self.latestDate = self.dataSourceArray[0].vitalsDate
            

            self.updateView()
        }
        
        print("Done view did load: VitalsController")
        
    }
    
    
    func checkHealthKitData(latestDate: NSDate, completion: ([Vitals]?, NSError!) -> Void ) {
        //let past = latestDate
        let rightNow   = NSDate()
        
        self.healthManager.readVitals(latestDate, endDate: rightNow, completion:  completion)
        
        
    }
    
    var dataSourceArray = [Vitals]()
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Most of the time my data source is an array of something...  will replace with the actual name of the data source
        return dataSourceArray.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string!
        let cell = tableView.dequeueReusableCellWithIdentifier("vitailsCellId")! as UITableViewCell

        let row = indexPath.row
        
        let dateFormatter = NSDateFormatter()
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let dateString = dateFormatter.stringFromDate(dataSourceArray[row].vitalsDate)
        cell.textLabel?.text =  "\(dataSourceArray[row].systolic) / \(dataSourceArray[row].diatolic) Pulse: \(dataSourceArray[row].pulse)"
        cell.detailTextLabel?.text = dateString
        // set cell's textLabel.text property
        // set cell's detailTextLabel.text property
        return cell
    }
    
    
    @IBAction func clickCheckHk(sender: AnyObject) {
        self.checkHealthKitData(self.dataSourceArray[0].vitalsDate, completion: { (hkItems, error) in
            print("Count: \(hkItems!.count)")
            for i in hkItems! {
                self.dataSourceArray.append(i)
            }
            self.dataSourceArray = self.dataSourceArray.sort(self.vitalDateSort)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                
                
            })
        })
        
        
    }
    
    
    // MARK : Get Data
    
    func updateView() {
        for w in dataSourceArray {
            print("\(w.vitalsDate) \(w.pulse)" )
        }
        

        self.dataSourceArray = self.dataSourceArray.sort({ (v1, v2) -> Bool in
            return v1.vitalsDate.timeIntervalSinceReferenceDate > v2.vitalsDate.timeIntervalSinceReferenceDate
        })
        
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            
            
        })
    }
    
    
    // With Alamofire
    //func fetchWeights() {
    func fetchWeights(count: Int, completion: ([Vitals]?) -> Void) {
        var items = [Vitals]()
        
        Alamofire.request(.GET, "https://www.schappet.com/automation/rest/vitals" , parameters: ["last": count])
            .validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        for (_,subJson):(String, JSON) in json {
                            let w = Vitals(jsonData: subJson)
                            items.append(w)
                            //print("JSON: \(index) \(w.person) \(w.weightInDate) \(w.value)")
                        }
                        completion(items)
                    }
                case .Failure(let error):
                    print(error)
                    completion(nil)
                }
        }
        
        
    }
    

    
}