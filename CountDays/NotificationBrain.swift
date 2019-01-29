//
//  NotificationBrain.swift
//  CountDays
//
//  Created by Dominic Lanzillotta on 8/12/18.
//  Copyright © 2018 Dominic Lanzillotta. All rights reserved.
//

import Foundation

///Everything Notification Related happens here
class NotificationBrain {
    ///variabale that tracks if notifications are allowed by user
    public var permissionGranted = false
    
    /**
     Schedules one local Notification.
    - Parameters:
        - schedulingTime: the date
        - alertMessage: what should the notification say
        - badgeCountValue: optional to have a count bigger then 1
     - Returns: positiv or negative feedback regading scheduling
     */
    public func scheduleNotification(schedulingTime when: Date, alertMessage text: String, badgeCountValue count: Int) -> Bool{
        return false
    }
    
    /**
     Change of Badge Number within the next 2 seconds of the functuon called.
     - Parameters:
        - count: the number the badge should read
     - Returns: positiv or negative feedback
     */
    public func changeBadge(count: Int) {
        
    }
    /**
     Schedules multiple local Notifications of the same content.
     - Parameters:
        - schedulingTime: the date
        - alertMessage: what should the notification say
        - badgeCountValue: optional to have a count bigger then 1
        - howOften: the amount of time the Notivacation should get called
     - Returns: positiv or negative feedback
     */
    public func scheduleRepeatNotification(schedulingTime when: Date, alertMessage text: String, badgeCountValue count: Int, howOften interval: Int) -> Bool {
        return false
    }
    /**
     Ask user permission to run
     - Returns: positiv or negative feedback
     */
    public func askForNotificationPermission() -> Bool{
        return false
    }
    
}
