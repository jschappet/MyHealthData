//
//  StepCountController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 6/8/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import HealthKit
import SwiftDate

class StepCountController:  UIViewController,  UITableViewDataSource, UITableViewDelegate {
    
    
    
    //var latestDate : NSDate?
    
    let healthManager:HealthManager = HealthManager()
    var settings : NSDictionary = [:]
    
    let entityType = "stepcount"
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let dateSort = { (v1: StepCount, v2: StepCount) -> Bool in
        return (v1.measureEndDate.timeIntervalSinceReferenceDate > v2.measureEndDate.timeIntervalSinceReferenceDate)
    }
    
    
    
    override func viewDidLoad() {
        
        
        settings = healthManager.getSettings()
        
        print("starting view did load: StepCountController")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fetch(25) { (items) in
            self.dataSourceArray = items!.sort(self.dateSort)
            
            
            self.updateView()
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(VitalsController.refresh(_:)) ,   forControlEvents: UIControlEvents.ValueChanged)
        tableView!.addSubview(refreshControl)
        print("Done view did load: StepCountController")
        
    }
    
    
    var refreshControl:UIRefreshControl!
    
    
    func refresh(sender:AnyObject)
    {
        
        print("refreshing")
        self.updateView()
        
        refreshControl?.endRefreshing()
    }
    
    
    func checkHealthKitData(latestDate: NSDate, completion: ([StepCount]?, NSError!) -> Void ) {
        //let past = latestDate
        let rightNow   = NSDate()
        
        self.healthManager.readStepCount(latestDate, endDate: rightNow, completion:  completion)
        
        
    }
    
    var dataSourceArray = [StepCount]()
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Most of the time my data source is an array of something...  will replace with the actual name of the data source
        return dataSourceArray.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string!
        let cell = tableView.dequeueReusableCellWithIdentifier("stepCountCellId")! as UITableViewCell
        
        let row = indexPath.row
        
        let dateFormatter = NSDateFormatter()
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let dateString = dateFormatter.stringFromDate(dataSourceArray[row].measureEndDate)
        cell.textLabel?.text =  "\(dataSourceArray[row].value)"
        cell.detailTextLabel?.text = dateString
        // set cell's textLabel.text property
        // set cell's detailTextLabel.text property
        return cell
    }
    
    
    @IBAction func clickCheckHk(sender: AnyObject) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        var vitalsDate : NSDate
        if (self.dataSourceArray.count > 0) {
            vitalsDate = self.dataSourceArray[0].measureEndDate + 1.minutes
        } else {
            vitalsDate = 1.years.ago
        }
       
            self.checkHealthKitData(vitalsDate, completion: { (hkItems, error) in
              print("Count: \(hkItems!.count)")
            
              self.post(hkItems!)
                for v in hkItems! {
                    self.dataSourceArray.append(v)
                }
              self.dataSourceArray = self.dataSourceArray.sort(self.dateSort)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                  self.tableView.reloadData()
                  UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                })
            })
       
        
    }
    
    
    // MARK : Get Data
    
    func updateView() {
        for w in dataSourceArray {
            print("\(w.measureEndDate) \(w.value)" )
        }
        
        self.dataSourceArray = self.dataSourceArray.sort(dateSort)
        
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
        })
    }
    
    
    
    // With Alamofire
    //func fetchWeights() {
    func fetch(count: Int, completion: ([StepCount]?) -> Void) {
        
        
        var items = [StepCount]()
        
        Alamofire.request(.GET, "\(settings.valueForKey("com.schappet.base.url") as! String)\(entityType)" , parameters: ["last": count])
            .validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        for (_,subJson):(String, JSON) in json {
                            let w = StepCount(jsonData: subJson)
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
    
    
    func post(items: [StepCount]) {
        for v in items {
            Alamofire.request(.POST, "\(settings.valueForKey("com.schappet.base.url") as! String)\(entityType)", parameters: v.json(), encoding: .JSON)
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        print(response)
                       // print(response.result.value)
                        
                    case .Failure(let error):
                        print (error)
                    }
                    
            }
        }
    }
    
}