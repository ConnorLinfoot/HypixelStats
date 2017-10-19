//
//  ExtensionDelegate.swift
//  HypixelStats WatchKit Extension
//
//  Created by Connor Linfoot on 29/09/2017.
//  Copyright © 2017 Connor Linfoot. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    var doTheUpdateStuff = true;

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        scheduleBG();
    }
    
    let timeInSeconds = 300; // 5 mins
    func scheduleBG() {
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow: TimeInterval(self.timeInSeconds)), userInfo: nil) { (error: Error?) in
            if let error = error {
                print("Error occured while scheduling background refresh: \(error.localizedDescription)")
            }
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        
//        lastComplicationUpdate = 0; // Reset this to force reload :)
        reloadComplications();
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("Background handle_ called")
        
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                reloadComplications();
                backgroundTask.setTaskCompletedWithSnapshot(false);
                scheduleBG();
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    var lastComplicationUpdate = 0.0;
    var timeBetweenUpdate = 10.0; // Time in seconds, on an actual watch this is usually not reached but just incase
    
    func reloadComplications() {
        if( lastComplicationUpdate != 0 && ( lastComplicationUpdate + timeBetweenUpdate ) > Date().timeIntervalSince1970 ) {
            return;
        }
        
        print("UPDATING COMPLICATIONS")
        lastComplicationUpdate = Date().timeIntervalSince1970;
        if let complications: [CLKComplication] = CLKComplicationServer.sharedInstance().activeComplications {
            if complications.count > 0 {
                for complication in complications {
                    CLKComplicationServer.sharedInstance().reloadTimeline(for: complication)
                    NSLog("Reloading complication \(complication.description)...")
                }
            }
        }
    }

}
