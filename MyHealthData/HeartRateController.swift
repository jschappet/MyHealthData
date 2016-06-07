//
//  HeartRateController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 6/6/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import HealthKit
import SwiftDate

class HeartRateController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //var latestDate : NSDate?
    
    let healthManager:HealthManager = HealthManager()
 
    var settings : NSDictionary = [:]
    
    let entityType = "heartrate"
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let heartRateDateSort = { (v1: HeartRate, v2: HeartRate) -> Bool in
        return (v1.measureDate.timeIntervalSinceReferenceDate > v2.measureDate.timeIntervalSinceReferenceDate)
    }
    
    
    override func viewDidLoad() {
        print("starting view did load: HeartRateController")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        settings = healthManager.getSettings()
 
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fetchHeartRate(25) { (items) in
            self.dataSourceArray = items!.sort(self.heartRateDateSort)
            
            //self.latestDate = self.dataSourceArray[0].vitalsDate
            
            
            self.updateView()
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(HeartRateController.refresh(_:)) ,   forControlEvents: UIControlEvents.ValueChanged)
        tableView!.addSubview(refreshControl)
        print("Done view did load: HeartRateController")
        
    }
    
    
    var refreshControl:UIRefreshControl!
    
    
    func refresh(sender:AnyObject)
    {
        
        print("refreshing")
        
        fetchHeartRate(25) { (items) in
            self.dataSourceArray = items!.sort(self.heartRateDateSort)
            
            //self.latestDate = self.dataSourceArray[0].vitalsDate
            
            
            self.updateView()
        }
        
        refreshControl?.endRefreshing()
    }
    
    
    func checkHealthKitData(latestDate: NSDate, completion: ([HeartRate]?, NSError!) -> Void ) {
        //let past = latestDate
        let rightNow   = NSDate()
        
        self.healthManager.readHeartRate(latestDate, endDate: rightNow, completion:  completion)
        
        
    }
    
    var dataSourceArray = [HeartRate]()
    
    
    
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
        
         let dateString = dateFormatter.stringFromDate(dataSourceArray[row].measureDate)
            cell.textLabel?.text =  "Heart Rate: \(dataSourceArray[row].value) "
            cell.detailTextLabel?.text = dateString
            // set cell's textLabel.text property
            // set cell's detailTextLabel.text property
        
        return cell
    }
    
    
    @IBAction func clickCheckHk(sender: AnyObject) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        var measureDate: NSDate
        
        if (self.dataSourceArray.count > 0) {
            measureDate = self.dataSourceArray[0].measureDate + 10.minutes
        } else {
            measureDate = 5.years.ago()
        }
        print("click check Hk: \(measureDate)" )
        
        self.checkHealthKitData(measureDate, completion: { (hkItems, error) in
            print("Count: \(hkItems!.count)")
            
            for i in hkItems! {
                
                self.dataSourceArray.append(i)
            }
            self.postHeartRate(hkItems!)
            self.dataSourceArray = self.dataSourceArray.sort(self.heartRateDateSort)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                
            })
        })
        print("done: click check Hk" )
        
        
    }
    
    
    // MARK : Get Data
    
    func updateView() {
        for w in dataSourceArray {
            print("\(w.measureDate) \(w.value)" )
        }
        
        self.dataSourceArray = self.dataSourceArray.sort(self.heartRateDateSort)
        
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
        })
    }
    
    
    // With Alamofire
    //func fetchWeights() {
    func fetchHeartRate(count: Int, completion: ([HeartRate]?) -> Void) {
        print("Fetching heartRate values")
        var items = [HeartRate]()
        
        Alamofire.request(.GET, "\(settings.valueForKey("com.schappet.base.url") as! String)\(entityType)" , parameters: ["last": count])
            .validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        for (_,subJson):(String, JSON) in json {
                            let w = HeartRate(jsonData: subJson)
                            items.append(w)
                        }
                        completion(items)
                    }
                case .Failure(let error):
                    print(error)
                    completion(nil)
                }
        }
        
        
    }
    
    
    func postHeartRate(heartRate: [HeartRate]) {
        print("Posting heartRate values: \(heartRate.count)")
        for v in heartRate {
            Alamofire.request(.POST, "\(settings.valueForKey("com.schappet.base.url") as! String)\(entityType)", parameters: v.json(), encoding: .JSON)
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        print(response)
                        print(response.result.value)
                        
                    case .Failure(let error):
                        print (error)
                    }
                    
            }
        }
    }
    
}