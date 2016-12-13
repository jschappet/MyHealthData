//
//  CBLConnections.swift
//  MyHealthData
//
//  Created by Schappet, James C on 12/12/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation


func createHealthDataDb() -> CBLDatabase {
    let dbname = "health_data"
    let options = CBLDatabaseOptions()
    options.create = true
    
    return try! CBLManager.sharedInstance().openDatabaseNamed(dbname, with: options)
}

func createSettingsDb() -> CBLDatabase {
    let dbname = "settings"
    let options = CBLDatabaseOptions()
    options.create = true
    
    return try! CBLManager.sharedInstance().openDatabaseNamed(dbname, with: options)
}


func getValue(database: CBLDatabase, key: String) -> String {
    let settingsDb = database
    
    
    print("getting setting for \(key)")
    print(settingsDb.documentCount)
    //let docId = "settings.base.url"
    let doc = settingsDb.document(withID: "setting_\(key)")
    let properties = doc?.properties
    let props = properties?["data"] as? [ String : String ]
    if let value = props?["value"]  {
        return value
    } else {
        return "NOTSET"
    }
    
}

func setSettingValue(database: CBLDatabase, key: String, value: String) {
    
    
    guard let doc = database.document(withID: "setting_\(key)") else {
        print("wont save, key exists: \(key)")
       return
    }
    let data = [ "value" : value ] as [String : Any]
    let properties : [String : Any] = [
        "data" : data
    ]
    
    do {
        print("adding properties")
        try doc.putProperties(properties)
        
    } catch  let error as NSError  {
        
        print("Attempting to update key: \(key) \(error)")
        do {
            try doc.update( {  (newRev) -> Bool in
                print(newRev["data"]!)
                newRev["data"] = data
                    print("returning true")
                return true
            } )
        } catch  let error as NSError  {
            print("could not set properties key exists: \(key) \(error)")
            return
        }
    }
    
}
