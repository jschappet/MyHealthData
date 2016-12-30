//
//  HeartRateController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 6/6/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit
import HealthKit
import SwiftDate

class HeartRateController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //var latestDate : NSDate?
    lazy var database = MyCBLService.sharedInstance.createHealthDataDb()

    let healthManager:HealthManager = HealthManager()
 
    var settings : NSDictionary = [:]
    
    let entityType = "heartrate"
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let vitalDateSort = { (v1: Vitals, v2: Vitals) -> Bool in
        return (v1.startDate.timeIntervalSinceReferenceDate > v2.startDate.timeIntervalSinceReferenceDate)
    }
    
    
    var itemQuery : CBLLiveQuery!
    var itemTitles : [CBLQueryRow]?
    var refreshControl:UIRefreshControl!
    
    
    func setupViewAndQuery() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let listsView = database.viewNamed("viewHeartRateByTitle")
        if listsView.mapBlock == nil {
            listsView.setMapBlock({ (doc,emit) in
                if let id = doc["_id"] as? String, id.hasPrefix("\(self.entityType)_") {
                    
                    if let data = doc["data"] as? [String : AnyObject] {
                        if let title = data["startDate"] as? String {
                            let startDate = title.dateFromISO8601
                            let yyyymmdd = formatter.string(from: startDate!)
                            emit(yyyymmdd, data["value"])
                        }
                        
                    }
                    
                }
            }, reduce: { (keys, values, reredeuce) in
                var total: Float = 0
                var min : Float = 2000
                var max : Float = 0
                for  item  in values {
                    if let i = item as? String {
                        if let val = Float(i) {
                           min = min < val ? min : val
                           max = max > val ? max : val
                           total = total + Float(i)!
                        }
                    }
                    
                }
                let avg = total/Float(values.count)
                return "Min: \(min) Max: \(max) Avg: \(avg)"
            }, version: "1.2")
            
        }
        
        itemQuery = listsView.createQuery().asLive()
        itemQuery.descending = true
        itemQuery.groupLevel = 1
        itemQuery.limit = 10000
        itemQuery.addObserver(self, forKeyPath: "rows", options: .new, context: nil)
        itemQuery.start()
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to Sync Health Data")
        self.refreshControl.addTarget(self, action: #selector(self.clickCheckHk(_:)) ,   for: UIControlEvents.valueChanged)
        tableView!.addSubview(refreshControl)
        
    }
    
    
    
    func reloadItems() {
        itemTitles = itemQuery.rows?.allObjects as? [CBLQueryRow] ?? nil
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        
        
        settings = healthManager.getSettings()
        
        print("starting view did load: HeartRateController")
        
        settings = healthManager.getSettings()
        
        super.viewDidLoad()
        
        setupViewAndQuery()
        
        print("Done view did load: HeartRateController")
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == itemQuery {
            reloadItems()
        }
    }
    
    func checkHealthKitData(_ latestDate: Date, completion: @escaping ([HeartRate]?, NSError?) -> Void ) {
        //let past = latestDate
        let rightNow   = Date()
        
        self.healthManager.readHeartRate(latestDate, endDate: rightNow, completion:  completion)
        
        
    }
    
    //var dataSourceArray = [Vitals]()
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Most of the time my data source is an array of something...  will replace with the actual name of the data source
        return itemTitles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string!
        let cell = tableView.dequeueReusableCell(withIdentifier: "heartRateCellId")! as UITableViewCell
        
        let row = self.itemTitles![indexPath.row] as CBLQueryRow
        cell.detailTextLabel?.text = row.value(forKey: "key") as? String
        if let myValue = row.value(forKey: "value") as? String  {
            cell.textLabel?.text = "\(myValue)"
        } else {
            cell.textLabel?.text = "ERROR"
        }
        return cell
    }
    
    
    @IBAction func clickCheckHk(_ sender: AnyObject) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var latestDate = Date.distantPast
        if (self.itemTitles?.count)! > 0 {
            if let myValue =  self.itemTitles?[0].value(forKey: "key") as? String  {
                print("My Value: \(myValue)")
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                latestDate = formatter.date(from: myValue)!
            }
        }
        self.checkHealthKitData(latestDate, completion: { (hkItems, error) in
            print("Count: \(hkItems!.count)")
            
            self.saveHKItems(hkItems: hkItems!)
            //self.dataSourceArray = self.dataSourceArray.sorted(by: self.dateSort)
            DispatchQueue.main.async(execute: { () -> Void in
                // self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.refreshControl?.endRefreshing()
                
                
            })
        })
        
    }
    
    func saveHKItems(hkItems: [HeartRate]) {
        
        
        if let mgr = try? CBLManager.sharedInstance()       {
            
            mgr.backgroundTellDatabaseNamed(database.name, to: { (bgdb: CBLDatabase!) -> Void in
                // Inside this block we can't use myDB; instead use the instance given (bgdb)
                
                
                for w in hkItems {
                    
                    let docId = "\(self.entityType)_\(w.uuid)"
                    guard let doc = bgdb.document(withID: docId) else {
                        print("wont save uuid exists: \(w.uuid)")
                        continue
                    }
                    
                    let properties : [String : Any] = [
                        "data" : [
                            "devicename" : w.deviceName,
                            "value" : w.value,
                            "startDate": "\(w.startDate.iso8601)",
                            "endDate": "\(w.endDate.iso8601)"
                            
                        ]
                    ]
                    do {
                        try doc.putProperties(properties)
                    } catch  let error as NSError  {
                        print("could not set properties uuid exists: \(w.uuid) \(error)")
                        continue
                    }
                    
                    
                }
            })
            
            
            
        }
        
    }
    

}
