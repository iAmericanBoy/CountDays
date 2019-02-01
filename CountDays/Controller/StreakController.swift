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
        } catch {
            print("Error loading fetchResultsController. \(String(describing: error)), \(error.localizedDescription)")
        }
    }
    
    //MARK: - CRUD
    //MARK: create
    func createStreakWith(name:String) {
        Streak(name: name, start: Calendar.current.startOfDay(for: Date()), end: nil, goal: 0, count: 1, finishedStreak: false, restartedStreak: false, badge: false, lastModified: Date())
        saveToPersistentStore()
    }
    
    //MARK: update
    func update(startDate: Date, ofStreak streak: Streak) {
        streak.start = startDate
        saveToPersistentStore()
    }
    func update(name: String, ofStreak streak: Streak) {
        streak.name = name
        saveToPersistentStore()
    }
    
    //MARK: add Goal
    func add(goal: Int, ofStreak streak: Streak) {
        streak.goal = Int32(goal)
        saveToPersistentStore()
    }
    
    //MARK: toggle Restart
    func restart(streak: Streak) {
        Streak(name: streak.name, start: streak.start, end: streak.end, goal: streak.goal, count: streak.count, finishedStreak: true, restartedStreak: true, badge: false, lastModified: Date())
        streak.start = Calendar.current.startOfDay(for: Date())
        streak.lastModified = Date()
        saveToPersistentStore()
    }
    
    //MARK: toggle Finish
    func finish(streak: Streak) {
        streak.end = Calendar.current.startOfDay(for: Date())
        streak.finishedStreak = true
        streak.badge = false
        streak.lastModified = Date()
        saveToPersistentStore()

    }
    
    //MARK: toggle Badge
    func toggle(badge: Bool, ofStreak streak: Streak) {
        streak.badge = badge
        saveToPersistentStore()
    }
    
    //MARK: delete
    func remove(streak: Streak) {
        if let moc = streak.managedObjectContext {
            moc.delete(streak)
            saveToPersistentStore()
        }
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
}
