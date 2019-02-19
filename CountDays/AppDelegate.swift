//
//  AppDelegate.swift
//  CountDays
//
//  Created by Dominic Lanzillotta on 8/7/18.
//  Copyright © 2018 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let defaults = UserDefaults.standard
    
    let notificationDelegate = CDNotificationDelegate()

    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        getNotificationSettings()
        migrateToAppGroup()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        
        let layout = UICollectionViewFlowLayout()
        
        window?.rootViewController = UINavigationController(rootViewController: StreakCollectionViewController(collectionViewLayout: layout))
        
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(3600)
        
        // Check if launched from notification
        // 1
        if launchOptions != nil {
            //set badgcount to the number saved in userdefaults as an int if it available if not just set it to 0
            UIApplication.shared.applicationIconBadgeNumber = defaults.object(forKey: "currentCount") as? Int ?? 0
        }
        return true
    }
    func application(_ application: UIApplication,performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        var currentDay = Date()

        if defaults.bool(forKey: "badgeOn") == true {
            currentDay = Calendar.current.startOfDay(for: currentDay)
            
            var streakStartDay = Date()
            if let startDayFromUserDefaults = defaults.object(forKey: "startDay") as? Date {
                streakStartDay = startDayFromUserDefaults
            }
            
            let managedContext = persistentContainer.viewContext
            let predicate = NSPredicate(format: "finishedStreak == false && badge == true")
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Streak")
            fetchRequest.predicate = predicate
            do {
                let badgeStreak = try managedContext.fetch(fetchRequest)
                for (streak) in badgeStreak.enumerated() {
                    streakStartDay = streak.element.value(forKey: "start") as! Date
                    streakStartDay = Calendar.current.startOfDay(for: streakStartDay)
                    defaults.set(streakStartDay, forKey: "startDay")
                }
            } catch {
            }
            
            
            
            let content = UNMutableNotificationContent()
            content.badge = Calendar.current.dateComponents([.day], from: streakStartDay , to: currentDay).day! + 2 as NSNumber
            
            // Configure the trigger for notification in 3 seconds
            let date = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date!)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            
            // Create the request object.
            let request = UNNotificationRequest(identifier: "CountCheck", content: content, trigger: trigger)
            
            // Schedule the request.
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error : Error?) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            }
        }
    }
    

    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        //called when running or suspended
        //set badgcount to the number saved in userdefaults as an int if it available if not just set it to 0
        UIApplication.shared.applicationIconBadgeNumber = defaults.object(forKey: "currentCount") as? Int ?? 0
    }
    
    // MARK: - Core Data stack
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        
        let container = NSPersistentContainer(name: "CountDays")
        
        var persistentStoreDescriptions: NSPersistentStoreDescription
        
        
        //new
        if defaults.bool(forKey: "migrationSuccess"){
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url:  FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.oskman.DaysInARowGroup")!.appendingPathComponent("CountDays.sqlite"))]
        }
        
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named 'Bundle identifier' in the application's documents Application Support directory.
        let urls = Foundation.FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    
    func migrateToAppGroup() {
        
        if defaults.bool(forKey: "migrationSuccess") {
            let userDefaults = UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")!
            userDefaults.set(true, forKey: "migrationSuccess")
        }
        let coordinator = CoreDataStack.container.persistentStoreCoordinator
        
        let oldStoreUrl = self.applicationDocumentsDirectory.appendingPathComponent("CountDays.sqlite")
        let directory: NSURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.oskman.DaysInARowGroup")! as NSURL
        let newStoreUrl = directory.appendingPathComponent("CountDays.sqlite")!
        
        print(newStoreUrl)
        var targetUrl : URL? = nil
        var needMigrate = false
        var needDeleteOld = false
        
        if FileManager.default.fileExists(atPath: oldStoreUrl.path){
            needMigrate = true
            targetUrl = oldStoreUrl
        }
        
        if let migrationSuccessIsTrue = UserDefaults.standard.object(forKey: "migrationSuccess") as? Bool {
                if FileManager.default.fileExists(atPath: newStoreUrl.path){
                    needMigrate = false
                    
                    targetUrl = newStoreUrl
                    
                    if FileManager.default.fileExists(atPath: oldStoreUrl.path){
                        needDeleteOld = true
                    }
                }
        } else {
            self.deleteDocumentAtUrl(url: newStoreUrl)
        }

        if targetUrl == nil {
            targetUrl = newStoreUrl
        }
        
        if needMigrate {
            if let store = coordinator.persistentStore(for: targetUrl!)
            {
                do {
                    try coordinator.migratePersistentStore(store, to: newStoreUrl, options: nil, withType: NSSQLiteStoreType)
                    
                    if FileManager.default.fileExists(atPath: newStoreUrl.path){
                        defaults.set(true, forKey: "migrationSuccess")
                        let userDefaults = UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")!
                        userDefaults.set(true, forKey: "migrationSuccess")
                    }
                } catch let error {
                    print("migrate failed with error : \(error)")
                }
            }
        }
        
        
        
        
    }
    
    
    func deleteDocumentAtUrl(url: URL){
        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        fileCoordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil, byAccessor: {
            (urlForModifying) -> Void in
            do {
                try FileManager.default.removeItem(at: urlForModifying)
            }catch let error {
                print("Failed to remove item with error: \(error.localizedDescription)")
            }
        })
    }
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print("Saving restarted streak error : \(error.localizedDescription)")

                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError

                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - Delegates
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge])
    }
    private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
}

