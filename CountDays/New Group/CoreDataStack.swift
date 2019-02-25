//
//  CoreDataStack.swift
//  CountDays
//
//  Created by Dominic Lanzillotta on 1/31/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataStack {
    
    static let container: NSPersistentContainer = {
        
//        let appName = Bundle.main.object(forInfoDictionaryKey: (kCFBundleNameKey as String)) as! String
        let container = NSPersistentContainer(name: "CountDays")

        let userDefaults = UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")!
        
        if userDefaults.bool(forKey: "migrationSuccess"){
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url:  FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.oskman.DaysInARowGroup")!.appendingPathComponent("CountDays.sqlite"))]
        }

        container.loadPersistentStores() { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    static var context: NSManagedObjectContext {

        return container.viewContext
        
    }
}
