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
  
  let healthKitStore:HKHealthStore = HKHealthStore()
  
  func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
  {
    // 1. Set the types you want to read from HK Store
    
    let healthKitTypesToRead: Set = [
      HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
      HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType)!,
      HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!,
      HKObjectType.workoutType()
      ]
    
    // 2. Set the types you want to write to HK Store
    let healthKitTypesToWrite: Set =  [
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
      HKQuantityType.workoutType()
      ]
    
    // 3. If the store is not available (for instance, iPad) return an error and don't go on.
    if !HKHealthStore.isHealthDataAvailable()
    {
      let error = NSError(domain: "edu.uiowa.icts.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
      if( completion != nil )
      {
        completion(success:false, error:error)
      }
      return;
    }
    
    // 4.  Request HealthKit authorization
    healthKitStore.requestAuthorizationToShareTypes(
      healthKitTypesToWrite, readTypes: healthKitTypesToRead) { (success, error) -> Void in
      
      if( completion != nil )
      {
        completion(success:success,error:error)
      }
    }
  }
  
    func getSettings() -> NSDictionary {
        
        if let path = NSBundle.mainBundle().pathForResource("MyHealthData", ofType: "plist"), dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            // use swift dictionary as normal
           return dict
        } else {
            return NSDictionary()
        }
    }
  
  func readProfile() -> ( age:Int?,  biologicalsex:HKBiologicalSexObject?, bloodtype:HKBloodTypeObject?)
  {
    var age:Int?
    
    // 1. Request birthday and calculate age
    do {
      let birthDay = try healthKitStore.dateOfBirth()
      let today = NSDate()
      let calendar = NSCalendar.currentCalendar()
        
      let differenceComponents = calendar.components(.Year,
                                                fromDate: birthDay,
                                                toDate: today,
                                                options: [])
       
      age = differenceComponents.year
  
    } catch {
      print("Error reading Birthday")
      
    }
    
    // 2. Read biological sex
    var biologicalSex: HKBiologicalSexObject?
    do {
      try biologicalSex = healthKitStore.biologicalSex()
    } catch {
      print("Error reading Biological Sex")
    }

    // 3. Read blood type
    var bloodType:HKBloodTypeObject?
    do {
      try bloodType = healthKitStore.bloodType()
    } catch {
      print("Error reading Blood Type")
    }
    
    // 4. Return the information read in a tuple
    return (age, biologicalSex, bloodType)
  }
  
  
  
  func readMostRecentSample(sampleType:HKSampleType , completion: ((HKSample!, NSError!) -> Void)!)
  {
    
    // 1. Build the Predicate
    let past = NSDate.distantPast()
    let now   = NSDate()
    let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate:now, options: .None)
    
    // 2. Build the sort descriptor to return the samples in descending order
    let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
    // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)
    let limit = 1
    
    // 4. Build samples query
    let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
    { (sampleQuery, results, error ) -> Void in
      
      if let queryError = error {
        completion(nil,queryError)
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
    self.healthKitStore.executeQuery(sampleQuery)
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
    
    
    func readHeartRate(startDate: NSDate, endDate: NSDate, completion: (([HeartRate]?, NSError!) -> Void)!) {
        var heartRates = [HeartRate]()
        print ("Getting data from: \(startDate) to: \(endDate)")
        guard let type = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else {
                // display error, etc...
            print("error getting data")

            return
        }
        
        //let startDate = NSDate.distantPast()
        //let endDate   = NSDate()
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: true)
        let sampleQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: 100, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
                print("got results: \(results!.count)")
                for r in results!
                {
                    if let data1 = r as? HKQuantitySample {
                        // TODO: Get HeartRate for the
                        let value1 = data1.quantity.doubleValueForUnit(HKUnit(fromString: "count/min"))
                        
                        let date = data1.endDate
                        let hr = HeartRate()
                        hr.measureDate = date
                        hr.value = "\(value1)"
                        heartRates.append(hr)
                        // print("\(date)  \(value1) / \(value2)")
                    }
                }
                completion(heartRates, error)
            
        }
        healthKitStore.executeQuery(sampleQuery)
    }

    
    
    func readStepCount(startDate: NSDate, endDate: NSDate, completion: (([StepCount]?, NSError!) -> Void)!) {
        var activities = [StepCount]()
        print ("Getting data from: \(startDate) to: \(endDate)")
        guard let type = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount) else {
            // display error, etc...
            print("error getting data")
            
            return
        }
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: true)
        let sampleQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1000, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
            print("got results: \(results!.count)")
            for r in results!
            {
                if let data1 = r as? HKQuantitySample {
                    // TODO: Get HeartRate for the
                    let value1 = data1.quantity.doubleValueForUnit(HKUnit.countUnit())
                    
                    let startDate = data1.startDate
                    let endDate = data1.endDate
                    let act = StepCount()
                    act.measureStartDate = startDate
                    act.measureEndDate = endDate
                    act.value = "\(value1)"
                    activities.append(act)
                    // print("\(date)  \(value1) / \(value2)")
                }
            }
            completion(activities, error)
            
        }
        healthKitStore.executeQuery(sampleQuery)
    }

    
    
    func readVitals(startDate: NSDate, endDate: NSDate, completion: (([Vitals]?, NSError!) -> Void)!) {
        var vitals = [Vitals]()
        
        guard let type = HKQuantityType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierBloodPressure),
            let systolicType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic),
            let diastolicType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic) else {
                // display error, etc...
                return
        }
        
        //let startDate = NSDate.distantPast()
        //let endDate   = NSDate()
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: true)
        let sampleQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: 100, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in
            
            if let dataList = results as? [HKCorrelation] {
                for data in dataList
                {
                    if let data1 = data.objectsForType(systolicType).first as? HKQuantitySample,
                        let data2 = data.objectsForType(diastolicType).first as? HKQuantitySample {
                        // TODO: Get HeartRate for the 
                        let value1 = data1.quantity.doubleValueForUnit(HKUnit.millimeterOfMercuryUnit())
                        let value2 = data2.quantity.doubleValueForUnit(HKUnit.millimeterOfMercuryUnit())
                        let date = data2.endDate
                        let v = Vitals()
                        v.vitalsDate = date
                        v.diatolic = Int(value2)
                        v.systolic = Int(value1)
                        vitals.append(v)
                       // print("\(date)  \(value1) / \(value2)")
                    }
                }
                completion(vitals, error)
            }
            
        }
        healthKitStore.executeQuery(sampleQuery)
    }
    
    
    
    
    
}