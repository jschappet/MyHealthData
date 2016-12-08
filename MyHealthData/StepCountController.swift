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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fetch(25) { (items) in
            self.dataSourceArray = items!.sorted(by: self.dateSort)
            
            
            self.updateView()
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(VitalsController.refresh(_:)) ,   for: UIControlEvents.valueChanged)
        tableView!.addSubview(refreshControl)
        print("Done view did load: StepCountController")
        
    }
    
    
    var refreshControl:UIRefreshControl!
    
    
    func refresh(_ sender:AnyObject)
    {
        
        print("refreshing")
        self.updateView()
        
        refreshControl?.endRefreshing()
    }
    
    
    func checkHealthKitData(_ latestDate: Date, completion: @escaping ([StepCount]?, NSError?) -> Void ) {
        //let past = latestDate
        let rightNow   = Date()
        
        self.healthManager.readStepCount(latestDate, endDate: rightNow, completion:  completion)
        
        
    }
    
    var dataSourceArray = [StepCount]()
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Most of the time my data source is an array of something...  will replace with the actual name of the data source
        return dataSourceArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string!
        let cell = tableView.dequeueReusableCell(withIdentifier: "stepCountCellId")! as UITableViewCell
        
        let row = (indexPath as NSIndexPath).row
        
        let dateFormatter = DateFormatter()
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateString = dateFormatter.string(from: dataSourceArray[row].measureEndDate as Date)
        cell.textLabel?.text =  "\(dataSourceArray[row].value)"
        cell.detailTextLabel?.text = dateString
        // set cell's textLabel.text property
        // set cell's detailTextLabel.text property
        return cell
    }
    
    
    @IBAction func clickCheckHk(_ sender: AnyObject) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var vitalsDate : Date
        if (self.dataSourceArray.count > 0) {
            vitalsDate = self.dataSourceArray[0].measureEndDate as Date + 1.minutes
        } else {
            vitalsDate = 1.years.ago()!
        }
       
            self.checkHealthKitData(vitalsDate, completion: { (hkItems, error) in
              print("Count: \(hkItems!.count)")
            
              self.post(hkItems!)
                for v in hkItems! {
                    self.dataSourceArray.append(v)
                }
              self.dataSourceArray = self.dataSourceArray.sorted(by: self.dateSort)
                DispatchQueue.main.async(execute: { () -> Void in
                  self.tableView.reloadData()
                  UIApplication.shared.isNetworkActivityIndicatorVisible = false
                })
            })
       
        
    }
    
    
    // MARK : Get Data
    
    func updateView() {
        for w in dataSourceArray {
            print("\(w.measureEndDate) \(w.value)" )
        }
        
        self.dataSourceArray = self.dataSourceArray.sorted(by: dateSort)
        
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        })
    }
    
    
    
    // With Alamofire
    //func fetchWeights() {
    func fetch(_ count: Int, completion: @escaping ([StepCount]?) -> Void) {
        
        
        var items = [StepCount]()
        
        Alamofire.request("\(settings.value(forKey: "com.schappet.base.url") as! String)\(entityType)" , parameters: ["last": count])
            .validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        for (_,subJson):(String, JSON) in json {
                            let w = StepCount(jsonData: subJson)
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
    
    
    func post(_ items: [StepCount]) {
        for v in items {
            Alamofire.request( "\(settings.value(forKey: "com.schappet.base.url") as! String)\(entityType)",
                    method: .post, parameters: v.json(), encoding: JSONEncoding.default)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        print(response)
                       // print(response.result.value)
                        
                    case .failure(let error):
                        print (error)
                    }
                    
            }
        }
    }
    
}
