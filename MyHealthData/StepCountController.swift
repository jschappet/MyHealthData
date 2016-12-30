//
//  StepCountController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 6/8/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit
import HealthKit
import SwiftDate

class StepCountController:  UIViewController,  UITableViewDataSource, UITableViewDelegate {
    
    lazy var database = MyCBLService.sharedInstance.createHealthDataDb()

    
    //var latestDate : NSDate?
    
    let healthManager:HealthManager = HealthManager()
    var settings : NSDictionary = [:]
    var refreshControl:UIRefreshControl!

    let entityType = "stepcount"
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    var itemQuery : CBLLiveQuery!
    var itemTitles : [CBLQueryRow]?
    
    
    func setupViewAndQuery() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let listsView = database.viewNamed("viewStepCountByTitle")
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
                for  item  in values {
                    if let i = item as? String {
                       // print(i)
                        total = total + Float(i)!
                    }
                    
                }
                return total
            },
              version: "1.9")
            
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

    }
    
    
    
    func reloadItems() {
        itemTitles = itemQuery.rows?.allObjects as? [CBLQueryRow] ?? nil
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        
        
        settings = healthManager.getSettings()
        
        print("starting view did load: StepCountController")
        
        settings = healthManager.getSettings()
        
        super.viewDidLoad()
        
        setupViewAndQuery()
        
        print("Done view did load: StepCountController")
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == itemQuery {
            reloadItems()
        }
    }
    
    func checkHealthKitData(_ latestDate: Date, completion: @escaping ([StepCount]?, NSError?) -> Void ) {
        //let past = latestDate
        let rightNow   = Date()
        //let latestDate = Date.distantPast
        print ("getting step count \(latestDate) \(rightNow)")
        self.healthManager.readStepCount(latestDate, endDate: rightNow, completion:  completion)
        
        
    }
    
    
    
    @IBAction func clickCheckHk(_ sender: AnyObject) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var latestDate: Date = 3.months.ago()!
        
        if (self.itemTitles?.count)! > 0 {

            if let myValue = self.itemTitles?[0].value(forKey: "key") as?  String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
                latestDate = latestDate > formatter.date(from: myValue)! ? latestDate : formatter.date(from: myValue)!
                
            }
        }
        print ("getting step count \(latestDate) ")
        
        self.checkHealthKitData(latestDate, completion: { (hkItems, error) in
           // print("Count: \(hkItems!.count)")
            
            self.saveHKItems(hkItems: hkItems!)
            //self.dataSourceArray = self.dataSourceArray.sorted(by: self.dateSort)
            DispatchQueue.main.async(execute: { () -> Void in
                // self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.refreshControl?.endRefreshing()

                
            })
        })
        
        
    }
    
    
    
    func saveHKItems(hkItems: [StepCount]) {
        
        //let options = CBLDatabaseOptions()
        //let dbname = "automation_jschappet"
        
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

    
    
    let dateSort = { (v1: StepCount, v2: StepCount) -> Bool in
        return (v1.endDate.timeIntervalSinceReferenceDate > v2.endDate.timeIntervalSinceReferenceDate)
    }
    
    
    var dataSourceArray = [StepCount]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Most of the time my data source is an array of something...  will replace with the actual name of the data source
        return itemTitles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string!
        let cell = tableView.dequeueReusableCell(withIdentifier: "stepCountCellId")! as UITableViewCell
        
        let row = self.itemTitles![indexPath.row] as CBLQueryRow
        cell.detailTextLabel?.text = row.value(forKey: "key") as? String
        print(row.value(forKey: "value") ?? "FOO")
        if let myValue = row.value(forKey: "value") as?  Float  {
            //if let value  = myValue   {
                          
                    cell.textLabel?.text = "\(myValue)"
                
            //}
            
            
        } else {
            cell.textLabel?.text = "ERROR"
        }
        return cell
    }
    
    // MARK : Get Data
    
    func updateView() {
        for w in dataSourceArray {
            print("\(w.endDate) \(w.value)" )
        }
        
        self.dataSourceArray = self.dataSourceArray.sorted(by: dateSort)
        
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        })
    }
    
    
    
}
