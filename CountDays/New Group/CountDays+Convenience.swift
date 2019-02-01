//
//  CountDays+Convenience.swift
//  CountDays
//
//  Created by Dominic Lanzillotta on 1/31/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CoreData

extension Streak {
    @discardableResult
    convenience init(name: String?, start: Date?, end: Date?, goal: Int32, count: Int32,finishedStreak: Bool, restartedStreak: Bool, badge: Bool, lastModified: Date? , context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.name = name
        self.start = start
        self.end = end
        self.goal = goal
        self.count = count
        self.finishedStreak = finishedStreak
        self.restartedStreak = restartedStreak
        self.badge = badge
        self.lastModified = lastModified
    }
}
