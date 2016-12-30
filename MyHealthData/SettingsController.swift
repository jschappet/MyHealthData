//
//  SettingsController.swift
//  MyHealthData
//
//  Created by Schappet, James C on 12/23/16.
//  Copyright © 2016 University of Iowa - ICTS. All rights reserved.
//

import Foundation
import UIKit

class SettingsController: UITableViewController,  UIPickerViewDataSource, UIPickerViewDelegate  {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Starting SettingsController")
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
    }
    
    
    var pickerDataSource = ["White", "Red", "Green", "Blue"];
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    @IBAction func closeSettings(_ sender: AnyObject) {
        let controllerId = "Welcome"
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: controllerId) as UIViewController
        self.present(initViewController, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Section: \((indexPath as NSIndexPath).section) Row: \((indexPath as NSIndexPath).row)" )
        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row)
        {
        case (0,0):
          print("health auth recieved.")
            
            
        default:
            break
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerDataSource[row]
    }

    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(row == 0)
        {
            self.view.backgroundColor = UIColor.white;
        }
        else if(row == 1)
        {
            self.view.backgroundColor = UIColor.red;
        }
        else if(row == 2)
        {
            self.view.backgroundColor =  UIColor.green;
        }
        else
        {
            self.view.backgroundColor = UIColor.blue;
        }
    }
    
}
