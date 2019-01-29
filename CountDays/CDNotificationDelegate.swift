//
//  CDNotificationDelegate.swift
//  CountDays
//
//  Created by Dominic Lanzillotta on 1/11/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData

class CDNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Play sound and show alert to the user
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let streakBot = CDStreakHandling()
        
        
        // Determine the user action
        switch response.actionIdentifier {
        case "Restart":
            streakBot.restartStreak()
        case "DO_NOTHING":
            print("DO_NOTHING")
        case "Finish":
            streakBot.finishStreak()
        default:
            print("Unknown action")
        }
        completionHandler()
    }
}

