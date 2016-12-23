//
//  SettingsController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 12/23/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit

class SettingsController: UIViewController,  UITableViewDataSource, UITableViewDelegate  {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Starting SettingsController")
        
    }
    
    @IBAction func closeSettings(_ sender: AnyObject) {
        let controllerId = "Welcome"
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: controllerId) as UIViewController
        self.present(initViewController, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string!
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId")! as UITableViewCell
        
        cell.textLabel?.text = "row text"
        
        cell.detailTextLabel?.text = "row subtext"
        
        return cell
    }
    
    
}
