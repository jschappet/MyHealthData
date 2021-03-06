//
//  HealthManager.swift
//  HKTutorial
//
//  Created by ernesto on 18/10/14.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import Foundation
import HealthKit

class HealthManager {
  
  let healthStore:HKHealthStore = HKHealthStore()
  
  func authorizeHealthKit(_ completion: ((_ success:Bool, _ error:NSError?) -> Void)!)
  {
    // 1. Set the types you want to read from HK Store
    
    let healthKitTypesToRead: Set = [
      HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
      HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!,
      HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
      HKObjectType.workoutType()
      ]
    
    // 2. Set the types you want to write to HK Store
    let healthKitTypesToWrite: Set =  [
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMassIndex)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
      HKQuantityType.workoutType()
      ]
    
    // 3. If the store is not available (for instance, iPad) return an error and don't go on.
    if !HKHealthStore.isHealthDataAvailable()
    {
      let error = NSError(domain: "edu.uiowa.icts.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
      if( completion != nil )
      {
        completion?(false, error)
      }
      return;
    }
    
    // 4.  Request HealthKit authorization
    healthStore.requestAuthorization(
      toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) -> Void in
      
      if( completion != nil )
      {
        completion?(success,error as NSError?)
      }
    }
  }
  
    func getSettings() -> NSDictionary {
        
        if let path = Bundle.main.path(forResource: "MyHealthData", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            // use swift dictionary as normal
           return dict as NSDictionary
        } else {
            return NSDictionary()
        }
    }
  
  func readProfile() -> ( age:Int?,  biologicalsex:HKBiologicalSexObject?, bloodtype:HKBloodTypeObject?)
  {
    var age:Int?
    
    // 1. Request birthday and calculate age
    do {
      let birthDay = try healthStore.dateOfBirth()
      let today = Date()
      let calendar = Calendar.current
        
      let differenceComponents = (calendar as NSCalendar).components(.year,
                                                from: birthDay,
                                                to: today,
                                                options: [])
       
      age = differenceComponents.year
  
    } catch {
      print("Error reading Birthday")
      
    }
    
    // 2. Read biological sex
    var biologicalSex: HKBiologicalSexObject?
    do {
      try biologicalSex = healthStore.biologicalSex()
    } catch {
      print("Error reading Biological Sex")
    }

    // 3. Read blood type
    var bloodType:HKBloodTypeObject?
    do {
      try bloodType = healthStore.bloodType()
    } catch {
      print("Error reading Blood Type")
    }
    
    // 4. Return the information read in a tuple
    return (age, biologicalSex, bloodType)
  }
  
  
  
  func readMostRecentSample(_ sampleType:HKSampleType , completion: ((HKSample?, NSError?) -> Void)!)
  {
    
    // 1. Build the Predicate
    let past = Date.distantPast
    let now   = Date()
    let mostRecentPredicate = HKQuery.predicateForSamples(withStart: past, end:now, options: HKQueryOptions())
    
    // 2. Build the sort descriptor to return the samples in descending order
    let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
    // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)
    let limit = 1
    
    // 4. Build samples query
    let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
    { (sampleQuery, results, error ) -> Void in
      
      if let queryError = error {
        completion?(nil,queryError as NSError?)
        return;
      }
      
      // Get the first sample
      let mostRecentSample = results!.first as? HKQuantitySample
      
      // Execute the completion closure
      if completion != nil {
        completion(mostRecentSample,nil)
      }
    }
    // 5. Execute the Query
    healthStore.execute(sampleQuery)
  }
  
  
  /*
  func saveBMISample(bmi:Double, date:NSDate ) {
    
    // 1. Create a BMI Sample
    let bmiType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)
    let bmiQuantity = HKQuantity(unit: HKUnit.countUnit(), doubleValue: bmi)
    let bmiSample = HKQuantitySample(type: bmiType!, quantity: bmiQuantity, startDate: date, endDate: date)
    
    // 2. Save the sample in the store
    healthKitStore.saveObject(bmiSample, withCompletion: { (success, error) -> Void in
      if( error != nil ) {
        print("Error saving BMI sample: \(error!.localizedDescription)")
      } else {
        print("BMI sample saved successfully!")
      }
    })
  }
  */
    
    
    
    
    
    func healthQuery<Type: HealthItem>(_ startDate: Date, endDate: Date, completion: (([Type]?, NSError?) -> Void)!) {
        var activities = [Type]()
        let template = Type();
        
        print ("Getting data from: \(startDate) to: \(endDate)")
        guard let type = HKQuantityType.quantityType(forIdentifier: template.identifier ) else {
            // display error, etc...
            print("error getting data")
            
            return
        }
        
        //let stepCountSource = MyCBLService.sharedInstance.getValue(key: "step.count.source")
        
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: true)
        let sampleQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: 10000, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
            print("got results: \(results!.count)")
            for r in results!
            {
                if let data1 = r as? HKQuantitySample {
                    //if (data1.sourceRevision.source.name == "Misfit") {
                    // TODO: Get HeartRate for the
                    
                    if (template.filter(data1)){
                        // print("Match: \(data1.sourceRevision.source.name)")
                        let act = Type(sample: data1)
                        
                        activities.append(act)
                    }
                    //}
                    // print("\(date)  \(value1) / \(value2)")
                }
            }
            completion?(activities, error as NSError?)
            
        }
        healthStore.execute(sampleQuery)
        
    }

    
    
    
    func readStepCount(_ startDate: Date, endDate: Date, completion: (([StepCount]?, NSError?) -> Void)!) {
        var activities = [StepCount]()
        print ("Getting data from: \(startDate) to: \(endDate)")
        guard let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            // display error, etc...
            print("error getting data")
            
            return
        }
        
        let stepCountSource = MyCBLService.sharedInstance.getValue(key: "step.count.source")
        
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: true)
        let sampleQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: 10000, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
            print("got results: \(results!.count)")
            for r in results!
            {
                if let data1 = r as? HKQuantitySample {
                    //if (data1.sourceRevision.source.name == "Misfit") {
                    // TODO: Get HeartRate for the
                    
                    if (data1.sourceRevision.source.name == stepCountSource){
                        // print("Match: \(data1.sourceRevision.source.name)")
                        let act = StepCount(sample: data1)
                        
                        activities.append(act)
                    }
                    //}
                    // print("\(date)  \(value1) / \(value2)")
                }
            }
            completion?(activities, error as NSError?)
            
        }
        healthStore.execute(sampleQuery)
    }

    func readHeartRate(_ startDate: Date, endDate: Date, completion: (([HeartRate]?, NSError?) -> Void)!) {
        var heartRates = [HeartRate]()
        print ("Getting data from: \(startDate) to: \(endDate)")
        guard let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
                // display error, etc...
            print("error getting data")

            return
        }
        
        //let startDate = NSDate.distantPast()
        //let endDate   = NSDate()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: true)
        let sampleQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: 5000, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
                print("got results: \(results!.count)")
                for r in results!
                {
                    if let data1 = r as? HKQuantitySample {
                        // TODO: Get HeartRate for the
                        
                        let hr = HeartRate(sample: data1)
                        
                        heartRates.append(hr)
                        // print("\(date)  \(value1) / \(value2)")
                    }
                }
                completion?(heartRates, error as NSError?)
            
        }
        healthStore.execute(sampleQuery)
    }
/*
    func todayTotalSteps(endDate: Date, completion: (_: Double) -> Void) {
        
        let calendar = Calendar.current
        var interval = DateComponents()
        interval.day = 7
        
        // Set the anchor date to Monday at 3:00 a.m.
        let anchorComponents = calendar.components([.Day, .Month, .Year, .Weekday], fromDate: Date())
        
        
        let offset = (7 + anchorComponents.weekday - 2) % 7
        anchorComponents.day -= offset
        anchorComponents.hour = 3
        
        guard let anchorDate = calendar.date(from: anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            fatalError("*** Unable to create a step count type ***")
        }
        
        // Create the query
        let stepsQuery = HKStatisticsCollectionQuery(quantityType: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: anchorDate!, intervalComponents: interval)

        
        // Set the results handler
        stepsQuery.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                // Perform proper error handling here
                fatalError("*** An error occurred while calculating the statistics: \(error?.localizedDescription) ***")
            }
            
            let endDate = Date()
            
            guard let startDate = calendar.dateByAddingUnit(.Month, value: -3, toDate: endDate, options: []) else {
                fatalError("*** Unable to calculate the start date ***")
            }
            
            // Plot the weekly step counts over the past 3 months
            statsCollection.enumerateStatisticsFromDate(startDate, toDate: endDate) { [unowned self] statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValueForUnit(HKUnit.countUnit())
                    
                    // Call a custom method to plot each data point.
                    self.plotWeeklyStepCount(value, forDate: date)
                }
            }
        }
        
        healthStore.executeQuery(stepsQuery)
    }
  */
    
    
 
    func readVitals(_ startDate: Date, endDate: Date, completion: (([Vitals]?, NSError?) -> Void)!) {
        var vitals = [Vitals]()
        
        guard let type = HKQuantityType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.bloodPressure),
            let systolicType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic),
            let diastolicType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic) else {
                // display error, etc...
                return
        }
        
        //let startDate = NSDate.distantPast()
        //let endDate   = NSDate()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: true)
        let sampleQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1000, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
            
            if let dataList = results as? [HKCorrelation] {
                for data in dataList
                {
                    if let data1 = data.objects(for: systolicType).first as? HKQuantitySample,
                        let data2 = data.objects(for: diastolicType).first as? HKQuantitySample {
                        // TODO: Get HeartRate for the 
                        let value1 = data1.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                        let value2 = data2.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                        let date = data2.endDate
                        var v = Vitals()
                        v.uuid = data.uuid
                        v.startDate = date
                        v.diatolic = Int(value2)
                        v.systolic = Int(value1)
                        v.deviceName =  data.sourceRevision.source.name
                        vitals.append(v)
                       // print("\(date)  \(value1) / \(value2)")
                    }
                }
                completion?(vitals, error as NSError?)
            }
            
        }
        healthStore.execute(sampleQuery)
    }
   
    
    
    
    
    func readWeight(_ startDate: Date, endDate: Date, completion: (([Weight]?, NSError?) -> Void)!) {
        var weights = [Weight]()
        print ("Getting data from: \(startDate) to: \(endDate)")
        guard let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass) else {
            // display error, etc...
            print("error getting data")
            
            return
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: true)
        let sampleQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: 10000, sortDescriptors: [sortDescriptor])
        { (sampleQuery, data, error ) -> Void in
            if let e = error {
                    print(e)
            } else {
            if let results = data {
                print("got results: \(results.count)")
            for r in results
                {
                if let data1 = r as? HKQuantitySample {
                    print(data1.sourceRevision.source.name)
                    //if (data1.sourceRevision.source.name == "Misfit") {
                        // TODO: Get HeartRate for the
                    let act = Weight(sample: data1)
                        weights.append(act)
                    //}
                    // print("\(date)  \(value1) / \(value2)")
                    }
                }
                completion?(weights, error as NSError?)
            
            }
          }
        }
        healthStore.execute(sampleQuery)
    }
    
    

}
