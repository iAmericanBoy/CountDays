//
//  StreakController.swift
//  CountDays
//
//  Created by Dominic Lanzillotta on 1/31/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CoreData

class StreakController {
    //MARK: - Singleton
    static let shared = StreakController()
    
    //MARK: - Sort Descriptor
    static var sortDescriptor: NSSortDescriptor {
        get {
            let key = UserDefaults.standard.string(forKey: "sortBy") ?? "name"
            return NSSortDescriptor(key: key , ascending: false)
        }
    }
    
    //MARK: - fetchResultsController
    let unfinishedStreakfetchResultsController: NSFetchedResultsController<Streak> = {
        let fetchRequest: NSFetchRequest<Streak> = Streak.fetchRequest()
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        let predicate = NSPredicate(format: "finishedStreak == false")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [nameSort]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    let finishedStreakfetchResultsController: NSFetchedResultsController<Streak> = {
        let fetchRequest:NSFetchRequest<Streak> = Streak.fetchRequest()
        let predicate = NSPredicate(format: "finishedStreak == true")
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    let unFinishedWithBadgeStreakfetchResultsController: NSFetchedResultsController<Streak> = {
        let fetchRequest:NSFetchRequest<Streak> = Streak.fetchRequest()
        let predicate = NSPredicate(format: "finishedStreak == false && badge == true")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSort]
        fetchRequest.predicate = predicate
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    let unFinishedWithReminderStreakfetchResultsController: NSFetchedResultsController<Streak> = {
        let fetchRequest:NSFetchRequest<Streak> = Streak.fetchRequest()
        let predicate = NSPredicate(format: "finishedStreak == false && dailyReminder == true")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSort]
        fetchRequest.predicate = predicate
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    }()


    
    //MARK: - init
    init() {
        do{
            try finishedStreakfetchResultsController.performFetch()
            try unfinishedStreakfetchResultsController.performFetch()
            try unFinishedWithBadgeStreakfetchResultsController.performFetch()
            try unFinishedWithReminderStreakfetchResultsController.performFetch()
        } catch {
            print("Error loading fetchResultsController. \(String(describing: error)), \(error.localizedDescription)")
        }
    }
    
    //MARK: - CRUD
    //MARK: create
    func createStreakWith(name:String) {
        Streak(name: name, start: Calendar.current.startOfDay(for: Date()), end: nil, goal: 0, count: 1, finishedStreak: false, restartedStreak: false, badge: false,reminder: false,lastModified: Date(), reminderText: nil, reminderTime: nil)
        saveToPersistentStore()
    }
    
    //MARK: update
    func update(startDate: Date, ofStreak streak: Streak) {
        streak.start = startDate
        setUUID(forStreak: streak)

        saveToPersistentStore()
    }
    func update(name: String, ofStreak streak: Streak) {
        streak.name = name
        setUUID(forStreak: streak)

        saveToPersistentStore()
    }
    
    //MARK: add Goal
    func add(goal: Int, ofStreak streak: Streak) {
        streak.goal = Int32(goal)
        setUUID(forStreak: streak)

        saveToPersistentStore()
    }
    
    //MARK: toggle Restart
    func restart(streak: Streak) {
        Streak(name: streak.name, start: streak.start, end: streak.end, goal: streak.goal, count: streak.count, finishedStreak: true, restartedStreak: true, badge: false, reminder: false, lastModified: Date(), reminderText: nil, reminderTime: nil)
        streak.start = Calendar.current.startOfDay(for: Date())
        streak.lastModified = Date()
        setUUID(forStreak: streak)
        
        saveToPersistentStore()
    }
    
    //MARK: toggle Finish
    func finish(streak: Streak) {
        streak.end = Calendar.current.startOfDay(for: Date())
        streak.finishedStreak = true
        streak.badge = false
        streak.lastModified = Date()
        setUUID(forStreak: streak)

        saveToPersistentStore()
    }
    
    //MARK: toggle Badge
    func toggle(badge: Bool, ofStreak streak: Streak) {
        streak.badge = badge
        setUUID(forStreak: streak)

        saveToPersistentStore()
    }
    
    //MARK: delete
    func remove(streak: Streak) {
        if let moc = streak.managedObjectContext {
            moc.delete(streak)
            saveToPersistentStore()
        }
    }
    
    //MARK: -  Reminder
    //MARK: toggle daily reminder
    func toggle(reminder: Bool, ofStreak streak: Streak) {
        streak.dailyReminder = reminder
        setUUID(forStreak: streak)

        saveToPersistentStore()
    }
    
    //MARK: set Reminder Text
    func set(reminderText: String, ofStreak streak: Streak) {
        streak.reminderText = reminderText
        setUUID(forStreak: streak)

        saveToPersistentStore()
    }
    
    //MARK: set Reminder Time
    func set(reminderTime: Date, ofStreak streak: Streak) {
        streak.reminderTime = reminderTime
        setUUID(forStreak: streak)
        saveToPersistentStore()
    }
    
    //MARK: - Persistance
    func saveToPersistentStore(){
        do {
            if CoreDataStack.context.hasChanges {
                try CoreDataStack.context.save()
            }
        } catch {
            print("Error saving: \(String(describing: error)) \(error.localizedDescription))")
        }
    }
    
    //MARK: - Private Functions
    private func setUUID(forStreak streak: Streak) {
        if streak.uuid == nil {
            streak.uuid = UUID()
            saveToPersistentStore()
        }
    }
}
