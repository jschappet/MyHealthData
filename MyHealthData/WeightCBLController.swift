//
//  WeightCBLController.swift
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


func createDatabase() -> CBLDatabase {
    let dbname = "automation_jschappet"
    let options = CBLDatabaseOptions()
    options.create = true
    
    return try! CBLManager.sharedInstance().openDatabaseNamed(dbname, with: options)
}


class WeightCBLController:  UIViewController,  UITableViewDataSource, UITableViewDelegate {
    
    lazy var database = createDatabase()
    
    
    //var latestDate : NSDate?
    
    let healthManager:HealthManager = HealthManager()
    var settings : NSDictionary = [:]
    
    let entityType = "weight"
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let dateSort = { (v1: Weight, v2: Weight) -> Bool in
        return (v1.weightInDate.timeIntervalSinceReferenceDate > v2.weightInDate.timeIntervalSinceReferenceDate)
        
    }
    
    var weightQuery : CBLLiveQuery!
    var weightTitles : [CBLQueryRow]?

    func setupViewAndQuery() {
        let listsView = database.viewNamed("viewWeightByTitle")
        if listsView.mapBlock == nil {
            listsView.setMapBlock({ (doc,emit) in
                if let id = doc["_id"] as? String, id.hasPrefix("weight") {
                    
                    if let data = doc["data"] as? [String : AnyObject] {
                        if let title = data["value"] as? String {
                            emit(title, data)
                        }
                        
                    }
                    
                }
            }, version: "1.0")
        }
        
        weightQuery = listsView.createQuery().asLive()
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
        
        print("starting view did load: VitalsController")
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        super.viewDidLoad()
      
        setupViewAndQuery()

        // Do any additional setup after loading the view, typically from a nib.

        
        //self.refreshControl = UIRefreshControl()
        //self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        //self.refreshControl.addTarget(self, action: #selector(WeightCBLController.refresh(_:)) ,   for: UIControlEvents.valueChanged)
        //tableView!.addSubview(refreshControl)
        print("Done view did load: WeightCBLController")
        
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
    
    var dataSourceArray = [Weight]()
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Most of the time my data source is an array of something...  will replace with the actual name of the data source
        return weightTitles?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string!
        let cell = tableView.dequeueReusableCell(withIdentifier: "weightCBLCellId")! as UITableViewCell
        
        let row = self.weightTitles![indexPath.row] as CBLQueryRow
        cell.textLabel?.text = row.value(forKey: "key") as? String
        if let myValue = row.value(forKey: "value") as? [ String : String] {
            cell.detailTextLabel?.text = myValue["weightInDate"] 
        }
        return cell
    }
    
    
    @IBAction func clickCheckHk(_ sender: AnyObject) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var latestDate : Date
        if (self.dataSourceArray.count > 0) {
            latestDate = self.dataSourceArray[0].weightInDate as Date + 10.minutes
        } else {
            latestDate = Date.distantPast
        }
        
        
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
        let dbname = "automation_jschappet"
        //.openDatabaseNamed(dbname, with: options)
        if let mgr = try? CBLManager.sharedInstance()       {
            
            mgr.backgroundTellDatabaseNamed(dbname, to: { (bgdb: CBLDatabase!) -> Void in
                // Inside this block we can't use myDB; instead use the instance given (bgdb)
                
                
                for w in hkItems {
                    
                    let docId = "weight_\(w.uuid)"
                    guard let doc = bgdb.document(withID: docId) else {
                        print("wont save uuid exists: \(w.uuid)")
                        continue
                    }
                    
                    let properties : [String : Any] = [
                        "data" : [
                            "devicename" : w.deviceName,
                            "value" : w.value,
                            "weightInDate": "\(w.weightInDate)"
                            
                        ]
                    ]
                    
                    
                    
                    
                    
                    do {
                        try doc.putProperties(properties)
                    } catch _ as NSError {
                        print("could not set properties uuid exists: \(w.uuid)")
                        continue
                    }
                    
                    
                }
            })
            
        
        
        }
        
    }
    
    
    // MARK : Get Data
    
    func updateView() {
        for w in dataSourceArray {
            print("\(w.weightInDate) \(w.value)" )
        }
        
        self.dataSourceArray = self.dataSourceArray.sorted(by: dateSort)
        
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        })
    }
    
    
    
    
    
}
