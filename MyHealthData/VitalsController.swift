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
import SwiftDate

class VitalsController:  UIViewController,  UITableViewDataSource, UITableViewDelegate {
    
    
    
    //var latestDate : NSDate?
    
    let healthManager:HealthManager = HealthManager()
    var settings : NSDictionary = [:]
    
    let entityType = "vitals"
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let vitalDateSort = { (v1: Vitals, v2: Vitals) -> Bool in
        return (v1.vitalsDate.timeIntervalSinceReferenceDate > v2.vitalsDate.timeIntervalSinceReferenceDate)
    }
    

    
    override func viewDidLoad() {
        

        settings = healthManager.getSettings()
        
        print("starting view did load: VitalsController")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fetchWeights(25) { (items) in
            self.dataSourceArray = items!.sorted(by: self.vitalDateSort)
            
            //self.latestDate = self.dataSourceArray[0].vitalsDate
            

            self.updateView()
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(VitalsController.refresh(_:)) ,   for: UIControlEvents.valueChanged)
        tableView!.addSubview(refreshControl)
        print("Done view did load: VitalsController")
        
    }
    
    
    var refreshControl:UIRefreshControl!
    
    
    func refresh(_ sender:AnyObject)
    {
        
        print("refreshing")
        
        
        fetchWeights(25) { (items) in
            self.dataSourceArray = items!.sorted(by: self.vitalDateSort)
            
            //self.latestDate = self.dataSourceArray[0].vitalsDate
            
            
            self.updateView()
        }
        
        refreshControl?.endRefreshing()
    }
    
    
    func checkHealthKitData(_ latestDate: Date, completion: @escaping ([Vitals]?, NSError?) -> Void ) {
        //let past = latestDate
        let rightNow   = Date()
        
        self.healthManager.readVitals(latestDate, endDate: rightNow, completion:  completion)
        
        
    }
    
    var dataSourceArray = [Vitals]()
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Most of the time my data source is an array of something...  will replace with the actual name of the data source
        return dataSourceArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string!
        let cell = tableView.dequeueReusableCell(withIdentifier: "vitailsCellId")! as UITableViewCell

        let row = (indexPath as NSIndexPath).row
        
        let dateFormatter = DateFormatter()
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateString = dateFormatter.string(from: dataSourceArray[row].vitalsDate as Date)
        cell.textLabel?.text =  "\(dataSourceArray[row].systolic) / \(dataSourceArray[row].diatolic)"
        cell.detailTextLabel?.text = dateString
        // set cell's textLabel.text property
        // set cell's detailTextLabel.text property
        return cell
    }
    
    
    @IBAction func clickCheckHk(_ sender: AnyObject) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var vitalsDate : Date
        if (self.dataSourceArray.count > 0) {
            vitalsDate = self.dataSourceArray[0].vitalsDate as Date + 10.minutes
        } else {
            vitalsDate = Date.distantPast
        }
        
        
        self.checkHealthKitData(vitalsDate, completion: { (hkItems, error) in
            print("Count: \(hkItems!.count)")
            
            self.postVitals(hkItems!)
            self.dataSourceArray = self.dataSourceArray.sorted(by: self.vitalDateSort)
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                
            })
        })
        
        
    }
    
    
    // MARK : Get Data
    
    func updateView() {
        for w in dataSourceArray {
            print("\(w.vitalsDate) \(w.pulse)" )
        }
        
        self.dataSourceArray = self.dataSourceArray.sorted(by: vitalDateSort)
        
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        })
    }
    
    
    
    // With Alamofire
    //func fetchWeights() {
    func fetchWeights(_ count: Int, completion: @escaping ([Vitals]?) -> Void) {
        
        
        var items = [Vitals]()
        
        Alamofire.request("\(settings.value(forKey: "com.schappet.base.url") as! String)\(entityType)" , parameters: ["last": count])
            .validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        for (_,subJson):(String, JSON) in json {
                            let w = Vitals(jsonData: subJson)
                            items.append(w)
                            //print("JSON: \(index) \(w.person) \(w.weightInDate) \(w.value)")
                        }
                        completion(items)
                    }
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
        }
        
        
    }
    

    func postVitals(_ vitals: [Vitals]) {
        for v in vitals {
            Alamofire.request("\(settings.value(forKey: "com.schappet.base.url") as! String)\(entityType)",
                    method: .post, parameters: v.json(),  encoding: JSONEncoding.default)
                .responseJSON { response in
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
