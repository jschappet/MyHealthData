//
//  WeightController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 12/8/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import HealthKit
import SwiftDate




class WeightController:  UIViewController,  UITableViewDataSource, UITableViewDelegate {
    
    lazy var database = createHealthDataDb()


    
    let healthManager:HealthManager = HealthManager()
    var settings : NSDictionary = [:]
    
    let entityType = "weight"
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let dateSort = { (v1: Weight, v2: Weight) -> Bool in
       return (v1.startDate.timeIntervalSinceReferenceDate > v2.startDate.timeIntervalSinceReferenceDate)
        
    }
    
    var weightQuery : CBLLiveQuery!
    var weightTitles : [CBLQueryRow]?

    func setupViewAndQuery() {
        
        let listsView = database.viewNamed("weightList")
        //listsView.delete()
        if listsView.mapBlock == nil {
            listsView.setMapBlock({ (doc,emit) in
                if let id = doc["_id"] as? String, id.hasPrefix("\(self.entityType)_") {
                    
                    if let data = doc["data"] as? [String : AnyObject] {
                        if let title = data["startDate"] as? String {
                           // let index = title.index(title.startIndex, offsetBy: 7)
                           // let yyyymm = title.substring(to: index)
                           emit(title, data)
                        }
                        
                    }
                    
                }
            }, version: "1.0")

        }
        print(listsView.totalRows)
        
        weightQuery = listsView.createQuery().asLive()
        weightQuery.descending = true
        
        weightQuery.addObserver(self, forKeyPath: "rows", options: .new, context: nil)
        weightQuery.start()
        
        
    }
    
    func reloadWeights() {
        weightTitles = weightQuery.rows?.allObjects as? [CBLQueryRow] ?? nil
        tableView.reloadData()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == weightQuery {
            reloadWeights()
        }
    }
    
    override func viewDidLoad() {
        
        
        settings = healthManager.getSettings()
        
        print("starting view did load: WeightController")
        super.viewDidLoad()
      
        setupViewAndQuery()
        print("Done view did load: WeightController")
        
    }
    
    
    var refreshControl:UIRefreshControl!
    
    
    func refresh(_ sender:AnyObject)
    {
        
        print("refreshing")
        

        
        refreshControl?.endRefreshing()
    }
    
    
    func checkHealthKitData(_ latestDate: Date, completion: @escaping ([Weight]?, NSError?) -> Void ) {
        //let past = latestDate
        let rightNow   = Date()
        
        self.healthManager.readWeight(latestDate, endDate: rightNow, completion:  completion)
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return weightTitles?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string!
        let cell = tableView.dequeueReusableCell(withIdentifier: "weightCBLCellId")! as UITableViewCell
        
        let row = self.weightTitles![indexPath.row] as CBLQueryRow
        cell.detailTextLabel?.text = row.value(forKey: "key") as? String
        //cell.textLabel?.text = row.value(forKey: "value") as? String
        if let myValue = row.value(forKey: "value") as? [ String : String] {
            cell.textLabel?.text = myValue["value"]
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
    
    func saveHKItems(hkItems: [Weight]) {
        
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
