//
//  LoginService.swift
//  MyHealthData
//
//  Created by James Schappet on 12/13/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation


public class LoginService : NSObject {

    //let settingsDb = CBLService.createSettingsDb()
    let healthDb = MyCBLService.sharedInstance.createHealthDataDb()
    
    class var sharedInstance : LoginService {
        struct Singleton {
            static let instance = LoginService()
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
    
    
    
    public func signOut() {
        
        do {
            try MyCBLService.sharedInstance.deleteSettingsDb()
            try healthDb.delete()
        } catch let error as NSError {
            print("could not long out: \(error)")
        }
      
        
    }
    
    public func isLoggedIn() -> Bool {
        //var loggedIn:Bool = false
        let username =  MyCBLService.sharedInstance.getValue( key: "database.user.name")
        return username != "NOTSET"
        //return loggedIn
    }
    
    
    
    public func loginWithCompletionHandler(username: String, password: String, completionHandler: ((_: String?) -> Void)!) -> () {
        
        let value = MyCBLService.sharedInstance.getValue(key: "base.replication.url")
        print("Base URL: \(value)")
        if value == "NOTSET" {
            MyCBLService.sharedInstance.setSettingValue( key: "base.replication.url", value: "https://data.schappet.com/")
        }
        print("Base URL: \(MyCBLService.sharedInstance.getValue(key: "base.replication.url"))")
        
        
        
        // signatureMethod: <#T##String#>)
        
        let stepCountSource = MyCBLService.sharedInstance.getValue(key: "step.count.source")
        print("Step Count Source: \(stepCountSource)")
        if stepCountSource == "NOTSET" {
            MyCBLService.sharedInstance.setSettingValue( key: "step.count.source", value: "James’s Apple Watch")
        }
        print("\(MyCBLService.sharedInstance.getValue(key: "step.count.source"))")
        
        var databaseUsername = MyCBLService.sharedInstance.getValue( key: "database.user.name")
        print("Database Username: \(databaseUsername)")
        if databaseUsername == "NOTSET" {
            MyCBLService.sharedInstance.setSettingValue( key: "database.user.name", value: username)
            databaseUsername = username
        }
        print("Database Username: \(databaseUsername)")
        
        let databaseName = MyCBLService.sharedInstance.getValue( key: "database.name")
        
        print("Database Name: \(databaseName)")
        if databaseName == "NOTSET" {
            let dbPrefix = "userdb-"
            var hexString : NSMutableString
            hexString = ""
            for byte in databaseUsername.data(using: String.Encoding.utf8)! {
                hexString.appendFormat("%02x", UInt(byte))
            }
            let hexvalue = String(hexString)
            
            let dbName = "\(dbPrefix)\(hexvalue)"
            MyCBLService.sharedInstance.setSettingValue( key: "database.name", value: dbName)
        }
        print("Database Name: \(MyCBLService.sharedInstance.getValue( key: "database.name"))")
        
        let databasePassword = MyCBLService.sharedInstance.getValue( key: "database.password")
        print(databasePassword)
        if databasePassword == "NOTSET" {
            MyCBLService.sharedInstance.setSettingValue(key: "database.password", value: password)
        }
        completionHandler(nil)
       
    }
    
    
}
