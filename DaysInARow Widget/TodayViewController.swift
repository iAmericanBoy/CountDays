//
//  TodayViewController.swift
//  DaysInARow Widget
//
//  Created by Dominic Lanzillotta on 10/18/18.
//  Copyright © 2018 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

@objc(TodayViewController)


class TodayViewController: UIViewController, NCWidgetProviding, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    var numberOfItems = 3
    
    var fetchedResultsController: NSFetchedResultsController<Streak>!

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initializeFetchedResultsController()
        if numberOfItems > 3 {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = sectionInsets
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WidgetStreakViewCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection =  .horizontal
            let itemHeight = view.bounds.height - 15
            layout.itemSize = CGSize(width: itemHeight, height: view.bounds.height - 2)
            let horizontalSpacing = (view.bounds.width - (itemHeight * 3)) / 4
            layout.minimumLineSpacing = horizontalSpacing
            layout.sectionInset = UIEdgeInsets(top: 2, left: horizontalSpacing, bottom: 0, right: horizontalSpacing)
        }
    }
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CountDays")
        
        var persistentStoreDescriptions: NSPersistentStoreDescription
        
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url:  FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.oskman.DaysInARowGroup")!.appendingPathComponent("CountDays.sqlite"))]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    func initializeFetchedResultsController() {
        
        let managedContext = persistentContainer.viewContext
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        let predicate = NSPredicate(format: "finishedStreak == false")
        
        let fetchRequest:NSFetchRequest<Streak> = Streak.fetchRequest()
        fetchRequest.sortDescriptors = [nameSort]
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
//        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    override func viewWillLayoutSubviews() {
        let frame = view.bounds
        collectionView?.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let unFinishedStreak = fetchedResultsController.object(at: indexPath )

        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! WidgetStreakViewCell
        cell.roundLable.text = String(unFinishedStreak.count)
        cell.streakName.text = unFinishedStreak.name
        if unFinishedStreak.goal != 0 {
            cell.progress = Double(Float(unFinishedStreak.count) / Float(unFinishedStreak.goal))
        } else {
            cell.progress = 1
        }
        return cell
    }
    
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        // toggle height in case of more/less button event
        if activeDisplayMode == .compact {
            self.preferredContentSize = CGSize(width: 0, height: 150)
        } else {
            self.preferredContentSize = CGSize(width: 0, height: 300)
        }
    }
}
