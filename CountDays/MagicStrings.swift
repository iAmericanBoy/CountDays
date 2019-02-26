//
//  MagicStrings.swift
//  CountDays
//
//  Created by Dominic Lanzillotta on 2/14/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation

struct UserInfoDictionary {
    ///Returns: "streakStart"
    static let start = "streakStart"
    ///Returns: "streakName"
    static let name = "streakName"
    ///Returns: "streakGoal"
    static let goal = "streakGoal"
    ///Returns: "uuid"
    static let uuid = "uuid"
}

struct UserNotificationIdentifier {
    ///Returns: "DailyReminder"
    static let daily = "DailyReminder"
    ///Returns: "CountCheck"
    static let countUpdate = "CountCheck"
    ///Returns: "DailyReminderCategory"
    static let dailyCategory = "DailyReminderCategory"
}
