//
//  ComplicationController.swift
//  HypixelStats WatchKit Extension
//
//  Created by Connor Linfoot on 29/09/2017.
//  Copyright © 2017 Connor Linfoot. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    @IBAction func onCloseApp(_ sender: Any) {
    }
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    var panicDrop = -1000; // If the player count drops this much panic! (Try and send a notifications?!)
    var lastCount = 0; // Stores the last count, allows panicDrop to work as well as a +/- indicator.

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        switch complication.family {
        case .utilitarianLarge:
            
            
//            template.textProvider = CLKSimpleTextProvider(text: formatter.string(from: date))
            
            let url = URL(string: "https://api.hypixel.net/playerCount?key=_REPLACE_WITH_KEY_")
            let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
                let template = CLKComplicationTemplateUtilitarianLargeFlat();
                guard data != nil else {
                    print("no data found: \(error)");
                    return;
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
//                        print(json);
                        let success = json["success"] as? Int // Okay, the `json` is here, let's get the value for 'success' out of it
                        
                        if( success == 1 ) {
                            let playerCount = json["playerCount"] as! Int
                            let numberFormatter = NumberFormatter()
                            numberFormatter.numberStyle = NumberFormatter.Style.decimal
                            let formattedNumber = numberFormatter.string(from: NSNumber(value:playerCount));
                            let change = playerCount - self.lastCount;
                            if( change < self.panicDrop ) {
                                // TODO Panic!
//                                WKInterfaceDevice.current().play(WKHapticType.notification) // haptic panic for now
                            }
                            
                            let changeFormatted = numberFormatter.string(from: NSNumber(value:change));
                            
                            print(formattedNumber! + " Online (" + ( change > 0 ? "+" : "" ) + changeFormatted! + ")");
                            
                            template.textProvider = CLKSimpleTextProvider(text: formattedNumber! + " Online (" + ( change > 0 ? "+" : "" ) + changeFormatted! + ")");
                            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template));
                            self.lastCount = playerCount;
                            return;
                        }
                    }
                } catch let parseError {
                    print(parseError)
                }
                
                template.textProvider = CLKSimpleTextProvider(text: "ERROR")
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
                
            }
            task.resume();
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "0")
            template.fillFraction = self.dayFraction
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "0")
            template.fillFraction = self.dayFraction
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            
        default:
            NSLog("%@", "Unknown complication type: \(complication.family)")
            handler(nil)
        }
        
    }
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        
        if complication.family == .utilitarianSmall {
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "64")
            template.fillFraction = self.dayFraction
            handler(template)
        } else if complication.family == .utilitarianLarge {
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: "64,533 Online")
            handler(template)
        } else {
            handler(nil)
        }
    }
    
    var dayFraction : Float {
        let now = Date()
        let calendar = Calendar.current
        let componentFlags = Set<Calendar.Component>([.year, .month, .day, .weekOfYear,  .hour, .minute, .second, .weekday, .weekdayOrdinal])
        var components = calendar.dateComponents(componentFlags, from: now)
        components.hour = 0
        components.minute = 0
        components.second = 0
        //        let startOfDay = calendar.date(from: components)!
        //        return Float(now.timeIntervalSince(startOfDay)) / Float(24*60*60)
        return 0
    }
    
}

