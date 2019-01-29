////
////  ViewLogicController.swift
////  CountDays
////
////  Created by Dominic Lanzillotta on 8/13/18.
////  Copyright © 2018 Dominic Lanzillotta. All rights reserved.
////
//
//import Foundation
//import CoreData
//import UIKit
//
//
/////Welp ViewController needs to go on a diet
//class StreakLogicController {
//    ///variabale that stores the users UserDefault's database
//    private let defaults = UserDefaults()
//    ///current Calandar
//    let calendar = Calendar.current
//
//
//    var currentStreaks:[NSManagedObject] = []
//
//    public var currentCount:Int{
//        get {
//            updateCount()
//            guard let count = currentStreaks.first?.value(forKey: "count") as? Int else { return 0 }
//            defaults.set(count, forKey: "currentCount")
//
//            return count
//        }
//
//    }
//
//    public var currentDay = Date()
//    public var startDay = Date()
//    public var restartValue = false
//    public var currentTitle = String()
//
//
//    /**
//     Checks if there are saved startDate and currentTitle in UserDefaults.
//
//     Function Does noting if the UserDefaults are not set
//
//     */
//    public func setCountAndName() -> (title: String, count:Int){
//        currentTitle = "Start new Streak"
//        getCurrentStreak()
//        if currentStreaks.count > 0 {
//            updateCount()
//            currentTitle = currentStreaks.first?.value(forKey: "name") as! String
//            startDay = currentStreaks.first?.value(forKey: "start") as! Date
//        }
//
//
//        return (currentTitle,currentCount)
//    }
//
//    /**
//     Saves the current streaks name, start date and notes if it was a restared streak.
//     */
//    public func saveStreak() {
//        //saveValues
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//
//        // 1
//        let managedContext = appDelegate.persistentContainer.viewContext
//        // 2
//        let predicate = NSPredicate(format: "name == %@ && finishedStreak == false", currentTitle)
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Streak")
//        fetchRequest.predicate = predicate
//
//        do {
//            let streakToBeSaved = try managedContext.fetch(fetchRequest)
//            streakToBeSaved.first?.setValue(restartValue, forKey: "restartedStreak")
//            streakToBeSaved.first?.setValue(currentDay, forKey: "end")
//            streakToBeSaved.first?.setValue(true, forKey: "finishedStreak")
//        } catch {
//
//        }
//
//        // 4
//        do {
//            try managedContext.save()
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//
//        startDay = currentDay
//    }
//    /**
//     Starts a new empty Streak
//     */
//    public func startEmptyStreak() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return }
//        // 1
//        let managedContext = appDelegate.persistentContainer.viewContext
//        // 2
//        let entity = NSEntityDescription.entity(forEntityName: "Streak", in: managedContext)!
//
//        let newStreak = NSManagedObject(entity: entity, insertInto: managedContext)
//        newStreak.setValue("Start new Streak", forKeyPath: "name")
//
//        // 4
//        do {
//            try managedContext.save()
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//        updateCount()
//    }
//
//    /**
//     Starts a new Streak
//     - Parameters:
//        - start : the beginning day of the Streak
//        - name : the name of the streak
//     */
//    public func startStreak(start: Date , name: String) {
//        restartValue = false
//        saveStartDate(date: start)
//        saveName(name: name)
//        updateCount()
//    }
//
//
//
//
//    /**
//     Saves the name of the  Streak.
//     - Parameters:
//        - name: the name of the Streak
//     */
//    public func saveName(name:String){
//        if name != "Start new Streak"{
//            startnewStreakEntity(name: name, start: startDay)
//            currentTitle = name
//        }
//    }
//
//    /**
//     Saves the start Date of the  Streak.
//     - Parameters:
//     - date: the start date of the Streak
//     */
//    public func saveStartDate(date: Date){
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let predicate = NSPredicate(format: "name == %@ && finishedStreak == false", currentTitle)
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Streak")
//        fetchRequest.predicate = predicate
//        do {
//            let streakToBeUpdated = try managedContext.fetch(fetchRequest)
//            streakToBeUpdated.first?.setValue(changeToMidnight(toChange: date), forKey: "start")
//        } catch { }
//
//        do {
//            try managedContext.save()
//        } catch {
//            // Do something in response to error condition
//        }
//
//        startDay=changeToMidnight(toChange: date)
//    }
//
//
//
//    /**
//    Changes a date Value to midnight
//     - Parameters:
//        - toChange: the date that needs to be changed
//     - Returns: the Date Value set to midnight
//     */
//    public func changeToMidnight(toChange: Date) -> Date {
//        return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: toChange)!
//    }
//
//    /**
//     Calculates the differece between a day and another day in days. Adds one to the value in order to count the first day aswell.
//     - Parameters:
//        - start: the beginning day
//        - end: the end day
//     - Returns: the difference between the two days as an Int
//     */
//    public func differenceInDays(start:Date,end:Date) -> Int {
//        return calendar.dateComponents([ .day], from: end , to: start).day! + 1
//    }
//
//
//    /**
//     Adds a new Entity to the managedContext "Streak"
//
//     Function inserts count as a differene of the start date and the current date
//     - Parameters:
//        - name: the name of the new streak
//        - start: the start date of the new streak
//     */
//    private func startnewStreakEntity(name: String, start: Date) {
//        print(name)
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return }
//
//        // 1
//        let managedContext = appDelegate.persistentContainer.viewContext
//        // 2
//        let entity = NSEntityDescription.entity(forEntityName: "Streak", in: managedContext)!
//        let predicate = NSPredicate(format: "name == %@ && finishedStreak == false", currentTitle)
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Streak")
//        fetchRequest.predicate = predicate
//
//        do {
//            let streaksToBeChecked = try managedContext.fetch(fetchRequest)
//            if streaksToBeChecked.count < 1 {
//                let newStreak = NSManagedObject(entity: entity, insertInto: managedContext)
//                newStreak.setValue(name, forKeyPath: "name")
//                newStreak.setValue(start, forKeyPath: "start")
//            }
//        } catch {
//
//        }
//
//        // 4
//        do {
//            try managedContext.save()
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//    }
//
//    private func updateCount(){
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Streak")
//        do {
//            let streaksToUpdate = try managedContext.fetch(fetchRequest)
//            for streakToUpdate in streaksToUpdate {
//                guard let start = streakToUpdate.value(forKey: "start") as? Date else {
//                    streakToUpdate.setValue(0, forKey: "count")
//                    break
//                }
//                var end = currentDay
//                if let endFromStreak = streakToUpdate.value(forKey: "end") as? Date {
//                    end = endFromStreak
//                }
//                streakToUpdate.setValue(differenceInDays(start: end, end: start), forKey: "count")
//            }
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
//    }
//
//    private func getCurrentStreak() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let predicate = NSPredicate(format: "finishedStreak == false")
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Streak")
//        fetchRequest.predicate = predicate
//
//        do {
//            currentStreaks =  try managedContext.fetch(fetchRequest)
//        } catch {
//
//        }
//    }
//}
