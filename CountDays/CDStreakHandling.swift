//
//  CDStreakHandling.swift
//  CountDays
//
//  Created by Dominic Lanzillotta on 1/11/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import CoreData

class CDStreakHandling: NSObject {
    
    let currentDay = Date()
    let startOfCurrentDay = Calendar.current.startOfDay(for: Date())
    
    var fetchedResultsController: NSFetchedResultsController<Streak>!
    
    

    override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        let predicate = NSPredicate(format: "finishedStreak == false && badge == true")

        let fetchRequest:NSFetchRequest<Streak> = Streak.fetchRequest()
        fetchRequest.sortDescriptors = [nameSort]
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    
    func restartStreak() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let restartedStreak = fetchedResultsController.fetchedObjects!.first!
        
        let newStreak = Streak(context: managedContext)
        newStreak.start = restartedStreak.start
        newStreak.name = restartedStreak.name
        newStreak.count = restartedStreak.count
        newStreak.goal = restartedStreak.goal
        newStreak.end = startOfCurrentDay
        newStreak.restartedStreak = true
        newStreak.finishedStreak = true
        newStreak.lastModified = Date.init()
        
        
        restartedStreak.start = startOfCurrentDay
        restartedStreak.finishedStreak = false
        restartedStreak.lastModified = Date.init()
        //restart Count
        UIApplication.shared.applicationIconBadgeNumber = 1
        restartedStreak.count = 1
        
        do {
            try managedContext.save()
        } catch let error {
            print("Saving restarted streak error : \(error.localizedDescription)")
        }
    }
    
    func finishStreak() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let currentStreak = fetchedResultsController.fetchedObjects!.first!
        currentStreak.end = currentDay
        currentStreak.finishedStreak = true
        currentStreak.badge = false
        currentStreak.lastModified = Date.init()
        UIApplication.shared.applicationIconBadgeNumber = 0
        do {
            try managedContext.save()
        } catch let error {
            print("Saving restarted streak error : \(error.localizedDescription)")
        }
    }
}
