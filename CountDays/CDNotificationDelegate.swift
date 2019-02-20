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
        
        let uuid = response.notification.request.content.userInfo[UserInfoDictionary.uuid] as! String
        StreakController.shared.findStreakWith(uuid: UUID(uuidString: uuid)) { (streak) in
            
            guard let streak = streak else {return}
            // Determine the user action
            switch response.actionIdentifier {
            case "restart":
                StreakController.shared.restart(streak: streak)
            case "finish":
                StreakController.shared.finish(streak: streak)
            case "continue":
                break;
            case "snooze" :
                let continueAction = UNNotificationAction(identifier: "continue", title: "Continue Streak", options: UNNotificationActionOptions(rawValue: 0))
                let snoozeAction = UNNotificationAction(identifier: "snooze", title: "Ask me again in 1 hour", options: UNNotificationActionOptions(rawValue: 0))
                
                
                let category = UNNotificationCategory(identifier: "DailyReminderCategory", actions: [continueAction,snoozeAction],intentIdentifiers: [], options: [])
                let content = response.notification.request.content
                let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: Date(timeIntervalSinceNow: 3600))

                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                // Create the request object.
                let request = UNNotificationRequest(identifier: "DailyReminder", content: content, trigger: trigger)
                
                // Schedule the request.
                let center = UNUserNotificationCenter.current()
                center.setNotificationCategories([category])

                center.add(request) { (error : Error?) in
                    if let theError = error {
                        print(theError.localizedDescription)
                    }
                    print("Added new notification with name:\(content.title), body: \(content.body) and userInfo: \(content.userInfo). Scheduled time: \(String(describing: request.trigger))")
                }
            case UNNotificationDefaultActionIdentifier:
                //open app
                print("opening app")
                
                let layout = UICollectionViewFlowLayout()

                let window = UIApplication.shared.delegate?.window
                window??.rootViewController?.present(UINavigationController(rootViewController: StreakCollectionViewController(collectionViewLayout: layout)), animated: false, completion: nil)

            default:
                print("Unknown action")
            }
            completionHandler()
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        let window = UIApplication.shared.delegate?.window
        let navController = window??.rootViewController as! UINavigationController
        navController.pushViewController(SaveScreenViewController(), animated: false)
    }
}

