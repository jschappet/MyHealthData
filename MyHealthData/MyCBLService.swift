//
//  MyCBLService.swift
//  MyHealthData
//
//  Created by Schappet, James C on 12/12/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation

public class MyCBLService {

    
    var pusher : CBLReplication!
    var puller : CBLReplication!
    
    public func deleteSettingsDb() -> Void  {
        do {
            try createSettingsDb().delete()
        } catch let error {
            print(error)
        }
        
    }
    
    class var sharedInstance : MyCBLService {
        struct Singleton {
            static let instance = MyCBLService()
        }
        
        // Check whether we already have an OAuthInfo instance
        // attached, if so don't initialiaze another one
        //  if Singleton.instance.tokenInfo == nil {
        // Initialize new OAuthInfo object
        //    Singleton.instance.tokenInfo = OAuthInfo()
        // }
        
        // Return singleton instance
        return Singleton.instance
    }
    
    public func startReplication() -> Void {
        let urlString = getValue( key: "base.replication.url")
        let databaseName = getValue( key: "database.name")
        let username = getValue( key: "database.user.name")
        let password = getValue( key: "database.password")
        let url = URL(string: "\(urlString)/\(databaseName)")!
        
        print("URL: \(urlString) user: \(username) database: \(databaseName)")
        
        
        pusher = createHealthDataDb().createPushReplication(url)
        let auth = CBLAuthenticator.basicAuthenticator(withName: username, password: password)
        pusher.authenticator = auth
        
        pusher.continuous = true
        puller = createHealthDataDb().createPullReplication(url)
        puller.authenticator = auth
        
        puller.continuous = true
        
        pusher.start()
        puller.start()

    }
    
    
    public func createHealthDataDb() -> CBLDatabase {
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
    
    
    public func getValue(key: String) -> String {
        let settingsDb = createSettingsDb()
        
        
        print("getting value for \(key)")
        print("Doc Count: \(settingsDb.documentCount)")
        let doc = settingsDb.document(withID: "setting_\(key)")
        let properties = doc?.properties
        let props = properties?["data"] as? [ String : String ]
        if let value = props?["value"]  {
            return value
        } else {
            return "NOTSET"
        }
        
    }
    
    public func setSettingValue(key: String, value: String) {
        
        
        guard let doc = createSettingsDb().document(withID: "setting_\(key)") else {
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

}
