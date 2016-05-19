//
//  WeightTableViewController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/19/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit
import HealthKit
import Alamofire
import SwiftyJSON

class WeightTableViewController: UITableViewController {
    
    
    var healthManager:HealthManager?
    var weight:HKQuantitySample?
    let kUnknownString   = "Unknown"
    
    
    @IBOutlet var ageLabel:UILabel!
    @IBOutlet var bloodTypeLabel:UILabel!
    @IBOutlet var biologicalSexLabel:UILabel!
    @IBOutlet var weightLabel:UILabel!
    @IBOutlet var heightLabel:UILabel!
    @IBOutlet var bmiLabel:UILabel!
    
    var weights = [Weight]()
    
    override func viewDidLoad() {
        
        //let myWeight = Weight(name: "Newest meal", photo: nil, rating: 5)
        //print("\(myWeight!.name)")
        //
        
        fetchWeights() {
            (weights) -> Void in
             self.weights = weights!
            updateView()
            
        }
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func updateView() {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateWeight()
    {
        // 1. Construct an HKSampleType for weight
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        
        // 2. Call the method to read the most recent weight sample
        healthManager!.readMostRecentSample(sampleType!, completion: { (mostRecentWeight, error) -> Void in
            
            if( error != nil )
            {
                print("Error reading weight from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            
            var weightLocalizedString = self.kUnknownString;
            // 3. Format the weight to display it on the screen
            self.weight = mostRecentWeight as? HKQuantitySample;
            if let kilograms = self.weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)) {
                let weightFormatter = NSMassFormatter()
                weightFormatter.forPersonMassUse = true;
                weightLocalizedString = weightFormatter.stringFromKilograms(kilograms)
            }
            
            // 4. Update UI in the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.weightLabel.text = weightLocalizedString
                //self.updateBMI()
                
            });
        });
    }
    
    // With Alamofire
    //func fetchWeights() {
    func fetchWeights(completion: ([Weight]?) -> Void) {
        var weights = [Weight]()
        
       Alamofire.request(.GET, "http://localhost:8080/rest/weight" , parameters: ["last": "100"])
            .validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    for (_,subJson):(String, JSON) in json {
                        let w = Weight(jsonData: subJson)
                        weights.append(w)
                        //print("JSON: \(index) \(w.person) \(w.weightInDate) \(w.value)")
                    }
                    completion(weights)
                }
            case .Failure(let error):
                print(error)
                completion(nil)
            }
        }
        
        
    }
   

}