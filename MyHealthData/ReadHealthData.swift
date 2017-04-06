//
//  ReadHealthData.swift
//  MyHealthData
//
//  Created by Schappet, James C on 4/3/17.
//  Copyright © 2017 University of Iowa - ICTS. All rights reserved.
//

import Foundation


class ReadHealthData {
    
    //var latestDate : NSDate?
    lazy var database = MyCBLService.sharedInstance.createHealthDataDb()
    
    let healthManager:HealthManager = HealthManager()
    
    func checkHealthKitData(_ latestDate: Date, completion: @escaping ([Weight]?, NSError?) -> Void ) {
        //let past = latestDate
        let rightNow   = Date()
        
        self.healthManager.readWeight(latestDate, endDate: rightNow, completion:  completion)
        
        
    }
    
    /*
    func clickCheckHk(_ sender: AnyObject) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let latestDate = Date.distantPast
        
        self.checkHealthKitData(latestDate, completion: { (hkItems, error) in
            print("Count: \(hkItems!.count)")
            
            self.saveHKItems(hkItems: hkItems!)
            //self.dataSourceArray = self.dataSourceArray.sorted(by: self.dateSort)
            DispatchQueue.main.async(execute: { () -> Void in
                // self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
               // self.refreshControl?.endRefreshing()
                
            })
        })
        
        
    }
 */
    
    
    /*
    func saveHKItems(hkItems: [Weight]) {
        
        //let options = CBLDatabaseOptions()
        //let dbname = "automation_jschappet"
        
        if let mgr = try? CBLManager.sharedInstance()       {
            
            mgr.backgroundTellDatabaseNamed(database.name, to: { (bgdb: CBLDatabase!) -> Void in
                // Inside this block we can't use myDB; instead use the instance given (bgdb)
                
                
                for w in hkItems {
                    
                 //   let docId = "\(self.entityType)_\(w.uuid)"
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
      */
    }
    
