//
//  WeightController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/23/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import HealthKit

class WeightController: UIViewController,  UITableViewDataSource, UITableViewDelegate{
    
    
    var weight:HKQuantitySample?
    let healthManager:HealthManager = HealthManager()
    var settings : NSDictionary = [:]
    
    let entityType = "weight"

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl:UIRefreshControl!

    
    override func viewDidLoad() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        print("starting view did load: WeightController")
        
        settings = healthManager.getSettings()

        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fetchWeights( 25) { (weights) in
            self.dataSourceArray = weights!.sorted(by: { (w1, w2)-> Bool in
                w1.startDate.timeIntervalSinceReferenceDate > w2.startDate.timeIntervalSinceReferenceDate
            })
            self.updateView()
         
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(VitalsController.refresh(_:)) ,   for: UIControlEvents.valueChanged)
        tableView!.addSubview(refreshControl)
        
        print("Done view did load: WeightController")
        
    }
    
    func refresh(_ sender:AnyObject)
    {
        
        print("refreshing")
        self.updateView()
        
        refreshControl?.endRefreshing()
    }
    
    
    
    var dataSourceArray = [Weight]()
    
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     // Most of the time my data source is an array of something...  will replace with the actual name of the data source
     return dataSourceArray.count
     
     }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "weightCellId")! as UITableViewCell
        let row = (indexPath as NSIndexPath).row
         
        let dateFormatter = DateFormatter()
         
         
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
         
        let dateString = dateFormatter.string(from: dataSourceArray[row].startDate as Date)
        cell.textLabel?.text =  "\(dataSourceArray[row].value)lbs"
        cell.detailTextLabel?.text = dateString
        // set cell's textLabel.text property
        // set cell's detailTextLabel.text property
        return cell
    }
    
    
    
    // MARK : Get Data
    
    func updateView() {
        for w in dataSourceArray {
            print("\(w.startDate) \(w.value)" )
        }
        DispatchQueue.main.async(execute: { () -> Void in
             self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }
    
    
    // With Alamofire
    //func fetchWeights() {
    func fetchWeights(_ count: Int, completion: @escaping ([Weight]?) -> Void) {
        var weights = [Weight]()
        let urlString  = "\(settings.value(forKey: "com.schappet.base.url") as! String)\(entityType)"
        print("Url String \(urlString)")
        Alamofire.request(urlString , parameters: ["last": count])
            .validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        for (_,subJson):(String, JSON) in json {
                            let w = Weight(jsonData: subJson)
                            weights.append(w)
                            //print("JSON: \(index) \(w.person) \(w.weightInDate) \(w.value)")
                        }
                        completion(weights)
                    }
                case .failure(let error):
                    print(error)
                    completion(weights)
                }
        }
        
        
    }


}
