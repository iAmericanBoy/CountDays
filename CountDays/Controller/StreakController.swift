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
        let fetchRequest: NSFetchRequest<Streak> = Streak.fetchRequest()
        let predicate = NSPredicate(format: "finishedStreak == true")
        //        fetchRequest.sortDescriptors = [sortBy]
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
    //MARK: update date, name
    //MARK: add Goal
    //MARK: toggle Restart
    //MARK: toggle Finish
    //MARK: toggle Badge
    //MARK: delete
    
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
