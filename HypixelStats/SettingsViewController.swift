//
//  SettingsViewController.swift
//  HypixelStats
//
//  Created by Connor Linfoot on 30/09/2017.
//  Copyright © 2017 Connor Linfoot. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var apiKeyField: UITextField!
    struct defaultsKeys {
        static let apiKey = "apiKey";
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let defaults = UserDefaults.standard;
        if let key = defaults.object(forKey: defaultsKeys.apiKey){
            apiKeyField.text = defaults.value(forKey: defaultsKeys.apiKey) as! String;
        } else {
            // not exist
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func saveButton(_ sender: Any) {
//        saveSettings();
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard;
        defaults.setValue(apiKeyField.text, forKey: defaultsKeys.apiKey);
        defaults.synchronize();
    }
    
    @IBAction func onEndAPIKey(_ sender: Any) {
        print("I work!")
    }
}
