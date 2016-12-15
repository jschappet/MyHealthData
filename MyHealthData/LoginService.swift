//
//  LoginService.swift
//  MyHealthData
//
//  Created by James Schappet on 12/13/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation


public class LoginService : NSObject {

    let settingsDb = createSettingsDb()

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
            try settingsDb.delete()
        } catch let error as NSError {
            print("could not long out: \(error)")
        }
      
        
    }
    
    public func isLoggedIn() -> Bool {
        //var loggedIn:Bool = false
        let username =  getValue(database: settingsDb, key: "database.user.name")
        return username != "NOTSET"
        //return loggedIn
    }
    
    
    
    public func loginWithCompletionHandler(username: String, password: String, completionHandler: ((error: String?) -> Void)!) -> () {
        
        // Try and get an OAuth token
        //exchangeTokenForUserAccessTokenWithCompletionHandler(username, password: password) { (oauthInfo, error) -> () in
        
        let settingsDb = createSettingsDb()
        
        let value = getValue(database: settingsDb, key: "base.replication.url")
        print(value)
        if value == "NOTSET" {
            setSettingValue(database: settingsDb, key: "base.replication.url", value: "http://www.schappet.com:5984/")
        }
        
        
        
        
        
        var databaseUsername = getValue(database: settingsDb, key: "database.user.name")
        print(databaseUsername)
        if databaseUsername == "NOTSET" {
            setSettingValue(database: settingsDb, key: "database.user.name", value: username)
            databaseUsername = "demouser"
        }
        
        let databaseName = getValue(database: settingsDb, key: "database.name")
        
        print(databaseName)
        if databaseName == "NOTSET" {
            let dbPrefix = "userdb-"
            let hexString = NSMutableString()
            for byte in databaseUsername.data(using: String.Encoding.utf8)! {
                hexString.appendFormat("%02x", UInt(byte))
            }
            let hexvalue = String(hexString)
            
            let dbName = "\(dbPrefix)\(hexvalue)"
            setSettingValue(database: settingsDb, key: "database.name", value: dbName)
        }
        
        
        let databasePassword = getValue(database: settingsDb, key: "database.password")
        print(databasePassword)
        if databasePassword == "NOTSET" {
            setSettingValue(database: settingsDb, key: "database.password", value: password)
        }
        
            var error: String? = nil
            if (error == nil) {
                
                // Everything worked and OAuthInfo was returned
               // self.tokenInfo = oauthInfo!
                completionHandler(error: nil)
            } else {
                
                // Something went wrong
                //self.tokenInfo = nil
                completionHandler(error: error)
            }
        }
    }
    
    
}
