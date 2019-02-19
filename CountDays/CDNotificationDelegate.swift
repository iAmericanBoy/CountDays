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
}

