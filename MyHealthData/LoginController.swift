//
//  LoginController.swift
//  MyHealthData
//
//  Created by James Schappet on 12/13/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit

class LoginController: UIViewController {
    
    let login_url = "http://www.schappet.com:5984/"
    let checksession_url = "http://www.schappet.com:5984/"
    
    @IBOutlet var username_input: UITextField!
    @IBOutlet var password_input: UITextField!
    @IBOutlet var login_button: UIButton!
    
    var login_session:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        username_input.text = "try@me.com"
        password_input.text = "test"
        
        
        let preferences = UserDefaults.standard
        if preferences.object(forKey: "session") != nil
        {
            login_session = preferences.object(forKey: "session") as! String
            check_session()
        }
        else
        {
            LoginToDo()
        }
        
        
    }
    
    func login_now(username:String, password:String)
    {
        let post_data: NSDictionary = NSMutableDictionary()
        
        
        post_data.setValue(username, forKey: "username")
        post_data.setValue(password, forKey: "password")
        
        let url:URL = URL(string: login_url)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        var paramString = ""
        
        
        for (key, value) in post_data
        {
            paramString = paramString + (key as! String) + "=" + (value as! String) + "&"
        }
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                
                return
            }
            
            
            
            let json: Any?
            
            do
            {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            }
            catch
            {
                return
            }
            
            guard let server_response = json as? NSDictionary else
            {
                return
            }
            
            
            if let data_block = server_response["data"] as? NSDictionary
            {
                if let session_data = data_block["session"] as? String
                {
                    self.login_session = session_data
                    
                    let preferences = UserDefaults.standard
                    preferences.set(session_data, forKey: "session")
                    
                    DispatchQueue.main.async(execute: self.LoginDone)
                }
            }
            
            
            
        })
        
        task.resume()
        
        
    }
    
    
    
    func check_session()
    {
        let post_data: NSDictionary = NSMutableDictionary()
        
        
        post_data.setValue(login_session, forKey: "session")
        
        let url:URL = URL(string: checksession_url)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        var paramString = ""
        
        
        for (key, value) in post_data
        {
            paramString = paramString + (key as! String) + "=" + (value as! String) + "&"
        }
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                
                return
            }
            
            
            let json: Any?
            
            do
            {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            }
            catch
            {
                return
            }
            
            guard let server_response = json as? NSDictionary else
            {
                return
            }
            
            if let response_code = server_response["response_code"] as? Int
            {
                if(response_code == 200)
                {
                    DispatchQueue.main.async(execute: self.LoginDone)
                    
                    
                }
                else
                {
                    DispatchQueue.main.async(execute: self.LoginToDo)
                }
            }
            
            
            
        })
        
        task.resume()
        
        
    }
    
    
    
    
    
    func LoginDone()
    {
        username_input.isEnabled = false
        password_input.isEnabled = false
        
        login_button.isEnabled = true
        
        
        login_button.setTitle("Logout", for: .normal)
    }
    
    func LoginToDo()
    {
        username_input.isEnabled = true
        password_input.isEnabled = true
        
        login_button.isEnabled = true
        
        
        login_button.setTitle("Login", for: .normal)
    }
    
    
    @IBAction func DoLogin(_ sender: AnyObject) {
        
        if(login_button.titleLabel?.text == "Logout")
        {
            let preferences = UserDefaults.standard
            preferences.removeObject(forKey: "session")
            
            LoginToDo()
        }
        else{
            login_now(username:username_input.text!, password: password_input.text!)
        }
        
    }
    
}
