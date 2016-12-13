//
//  AppDelegate.swift
//  MyHealthData
//
//  Created by Schappet, James C on 5/18/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import UIKit



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    lazy var database = createHealthDataDb()
    lazy var settingsDb = createSettingsDb()
    
    var pusher : CBLReplication!
    var puller : CBLReplication!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
      
        let urlString = getValue(database: settingsDb, key: "base.replication.url")
        let databaseName = getValue(database: settingsDb, key: "database.name")
        let username = getValue(database: settingsDb, key: "database.user.name")
        let password = getValue(database: settingsDb, key: "database.password")
        let url = URL(string: "\(urlString)/\(databaseName)")!
        
        print("URL: \(urlString) user: \(username) password: \(password)")
        
        
        pusher = database.createPushReplication(url)
        let auth = CBLAuthenticator.basicAuthenticator(withName: username, password: password)
        pusher.authenticator = auth
        
        pusher.continuous = true
        puller = database.createPullReplication(url)
        puller.authenticator = auth
        
        puller.continuous = true
        
        pusher.start()
        puller.start()
    
        let controllerId = "Login";

        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: controllerId) as UIViewController
        self.window?.rootViewController = initViewController
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

