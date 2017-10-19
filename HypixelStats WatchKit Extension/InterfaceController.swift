//
//  InterfaceController.swift
//  HypixelStats WatchKit Extension
//
//  Created by Connor Linfoot on 29/09/2017.
//  Copyright © 2017 Connor Linfoot. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var playerCountLabel: WKInterfaceLabel!
    struct defaultsKeys {
        static let apiKey = "apiKey";
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func reloadButton() {
        let url = URL(string: "https://api.hypixel.net/playerCount?key=_REPLACE_WITH_KEY_")
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            guard data != nil else {
                print("no data found: \(error)");
                return;
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    print(json);
                    let success = json["success"] as? Int // Okay, the `json` is here, let's get the value for 'success' out of it
                    
                    if( success == 1 ) {
                        let playerCount = json["playerCount"] as! Int
                        let numberFormatter = NumberFormatter()
                        numberFormatter.numberStyle = NumberFormatter.Style.decimal
                        let formattedNumber = numberFormatter.string(from: NSNumber(value:playerCount))
                        self.playerCountLabel.setText(formattedNumber! + " Online");
                        return;
                    }
                }
            } catch let parseError {
                print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
            }
            
            self.playerCountLabel.setText("ERROR");
            
        }
        task.resume()
        
        
        self.playerCountLabel.setText("Loading...");
    }
    
    @IBAction func onTestSettings() {
        let defaults = UserDefaults.standard;
        if let key = defaults.object(forKey: defaultsKeys.apiKey){
            self.playerCountLabel.setText( defaults.value(forKey: defaultsKeys.apiKey) as! String );
        } else {
            self.playerCountLabel.setText("Error");
        }
    }
    
    @IBAction func testNotification() {
        let h0 = { print("ok")}
        
        let action1 = WKAlertAction(title: "Approve", style: .default, handler:h0)
        let action2 = WKAlertAction(title: "Decline", style: .destructive) {}
        let action3 = WKAlertAction(title: "Cancel", style: .cancel) {}
        
        presentAlert(withTitle: "Voila", message: "", preferredStyle: .actionSheet, actions: [action1, action2,action3])


    }
    
}
