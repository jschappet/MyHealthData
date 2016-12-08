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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        settings = healthManager.getSettings()
 
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fetchHeartRate(25) { (items) in
            self.dataSourceArray = items!.sorted(by: self.heartRateDateSort)
            
            //self.latestDate = self.dataSourceArray[0].vitalsDate
            
            
            self.updateView()
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(HeartRateController.refresh(_:)) ,   for: UIControlEvents.valueChanged)
        tableView!.addSubview(refreshControl)
        print("Done view did load: HeartRateController")
        
    }
    
    
    var refreshControl:UIRefreshControl!
    
    
    func refresh(_ sender:AnyObject)
    {
        
        print("refreshing")
        
        fetchHeartRate(25) { (items) in
            self.dataSourceArray = items!.sorted(by: self.heartRateDateSort)
            
            //self.latestDate = self.dataSourceArray[0].vitalsDate
            
            
            self.updateView()
        }
        
        refreshControl?.endRefreshing()
    }
    
    
    func checkHealthKitData(_ latestDate: Date, completion: @escaping ([HeartRate]?, NSError?) -> Void ) {
        //let past = latestDate
        let rightNow   = Date()
        
        self.healthManager.readHeartRate(latestDate, endDate: rightNow, completion:  completion)
        
        
    }
    
    var dataSourceArray = [HeartRate]()
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Most of the time my data source is an array of something...  will replace with the actual name of the data source
        return dataSourceArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string!
        let cell = tableView.dequeueReusableCell(withIdentifier: "heartRateCellId")! as UITableViewCell
        
        let row = (indexPath as NSIndexPath).row
        
        let dateFormatter = DateFormatter()
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
         let dateString = dateFormatter.string(from: dataSourceArray[row].measureDate as Date)
            cell.textLabel?.text =  "Heart Rate: \(dataSourceArray[row].value) "
            cell.detailTextLabel?.text = dateString
            // set cell's textLabel.text property
            // set cell's detailTextLabel.text property
        
        return cell
    }
    
    
    @IBAction func clickCheckHk(_ sender: AnyObject) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var measureDate: Date
        
        if (self.dataSourceArray.count > 0) {
            measureDate = self.dataSourceArray[0].measureDate as Date + 10.minutes
        } else {
            measureDate = 5.years.ago()!
        }
        print("click check Hk: \(measureDate)" )
        
        self.checkHealthKitData(measureDate, completion: { (hkItems, error) in
            print("Count: \(hkItems!.count)")
            
            for i in hkItems! {
                
                self.dataSourceArray.append(i)
            }
            self.postHeartRate(hkItems!)
            self.dataSourceArray = self.dataSourceArray.sorted(by: self.heartRateDateSort)
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                
            })
        })
        print("done: click check Hk" )
        
        
    }
    
    
    // MARK : Get Data
    
    func updateView() {
        for w in dataSourceArray {
            print("\(w.measureDate) \(w.value)" )
        }
        
        self.dataSourceArray = self.dataSourceArray.sorted(by: self.heartRateDateSort)
        
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        })
    }
    
    
    // With Alamofire
    //func fetchWeights() {
    func fetchHeartRate(_ count: Int, completion: @escaping ([HeartRate]?) -> Void) {
        print("Fetching heartRate values")
        var items = [HeartRate]()
        
        Alamofire.request(  "\(settings.value(forKey: "com.schappet.base.url") as! String)\(entityType)" , parameters: ["last": count])
            .validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        for (_,subJson):(String, JSON) in json {
                            let w = HeartRate(jsonData: subJson)
                            items.append(w)
                        }
                        completion(items)
                    }
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
        }
        
        
    }
    
    
    func postHeartRate(_ heartRate: [HeartRate]) {
        print("Posting heartRate values: \(heartRate.count)")
        let urlString = settings.value(forKey: "com.schappet.base.url") as! String
        let newUrlString = "\(urlString)\(entityType)"
        for v in heartRate {
            /*
            Alamofire.request("\(urlString)\(entityType)", method: .post, parameters: ["foo": "bar"], encoding: .json )
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        print(response)
                        print(response.result.value)
                        
                    case .failure(let error):
                        print (error)
                    }
                    
            }
            */
            Alamofire.request( newUrlString , method: .post, parameters: v.json(),  encoding: JSONEncoding.default)
                .validate().responseJSON { response in
                    switch response.result {
                    case .success:
                        print(response)
                        print(response.result.value)
                        
                    case .failure(let error):
                        print (error)
                    }
            }
        }
    }
    
}
