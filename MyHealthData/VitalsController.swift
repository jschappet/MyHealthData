//
//  VitalsController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/25/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit
import HealthKit
import SwiftDate

class VitalsController:  UIViewController,  UITableViewDataSource, UITableViewDelegate {
    //var latestDate : NSDate?
    
    let healthManager:HealthManager = HealthManager()
    var settings : NSDictionary = [:]

    lazy var database = MyCBLService.sharedInstance.createHealthDataDb()

    let entityType = "vitals"
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let vitalDateSort = { (v1: Vitals, v2: Vitals) -> Bool in
        return (v1.startDate.timeIntervalSinceReferenceDate > v2.startDate.timeIntervalSinceReferenceDate)
    }
    
    
    var itemQuery : CBLLiveQuery!
    var itemTitles : [CBLQueryRow]?
    
    
    func setupViewAndQuery() {
        let listsView = database.viewNamed("viewVitalsByTitle")
        if listsView.mapBlock == nil {
            listsView.setMapBlock({ (doc,emit) in
                if let id = doc["_id"] as? String, id.hasPrefix("\(self.entityType)_") {
                    
                    if let data = doc["data"] as? [String : AnyObject] {
                        if let title = data["startDate"] as? String {
                            emit(title, data)
                        }
                        
                    }
                    
                }
            }, version: "1.0")
            
        }
        
        itemQuery = listsView.createQuery().asLive()
        itemQuery.descending = true
        
        itemQuery.addObserver(self, forKeyPath: "rows", options: .new, context: nil)
        itemQuery.start()
    }
    
    
    
    func reloadItems() {
        itemTitles = itemQuery.rows?.allObjects as? [CBLQueryRow] ?? nil
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        

        settings = healthManager.getSettings()
        
        print("starting view did load: VitalsController")
 
        settings = healthManager.getSettings()
        
        super.viewDidLoad()
        
        setupViewAndQuery()

        print("Done view did load: VitalsController")
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == itemQuery {
            reloadItems()
        }
    }
    
    func checkHealthKitData(_ latestDate: Date, completion: @escaping ([Vitals]?, NSError?) -> Void ) {
        //let past = latestDate
        let rightNow   = Date()
        
        self.healthManager.readVitals(latestDate, endDate: rightNow, completion:  completion)
        
        
    }
    
    //var dataSourceArray = [Vitals]()
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Most of the time my data source is an array of something...  will replace with the actual name of the data source
        return itemTitles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string!
        let cell = tableView.dequeueReusableCell(withIdentifier: "vitalsCellId")! as UITableViewCell
        
        let row = self.itemTitles![indexPath.row] as CBLQueryRow
        cell.detailTextLabel?.text = row.value(forKey: "key") as? String
        if let myValue = row.value(forKey: "value") as? [ String : Any] {
            if let sys  = myValue["systolic"] as! Int?  {
                
                if let dia  = myValue["diatolic"] as! Int? {
                    cell.textLabel?.text = "\(sys)/\(dia)"
                }
            }
            
            
        } else {
            cell.textLabel?.text = "ERROR"
        }
        return cell
    }
    
    
    @IBAction func clickCheckHk(_ sender: AnyObject) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let latestDate = Date.distantPast
        
        self.checkHealthKitData(latestDate, completion: { (hkItems, error) in
            print("Count: \(hkItems!.count)")
            
            self.saveHKItems(hkItems: hkItems!)
            //self.dataSourceArray = self.dataSourceArray.sorted(by: self.dateSort)
            DispatchQueue.main.async(execute: { () -> Void in
                // self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                
            })
        })
        
    }
    
    func saveHKItems(hkItems: [Vitals]) {
        
        
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
                            "systolic" : w.systolic,
                            "diatolic" : w.diatolic,
                            "startDate": "\(w.startDate)",
                            "endDate": "\(w.endDate)"
                            
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
