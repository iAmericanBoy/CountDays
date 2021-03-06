//
//  StreakCollectionViewController.swift
//  CountDays
//
//  Created by Dominic Lanzillotta on 9/14/18.
//  Copyright © 2018 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import CoreData
import StoreKit

import os




@available(iOS 12.0, *)

class StreakCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CollectionViewCellDelegate, CollectionViewHeaderDelegate, CollectionViewFooterDelegate {
    
    var fetchedResultsController: NSFetchedResultsController<Streak>!

    let defaults = UserDefaults.standard

    let calendar = Calendar.current

    var currentDay = Calendar.current.startOfDay(for: Date())
    
    private let cellIdentifier = "Cell"
    private let headerId = "headerId"
    var showBadge = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
        setupPaging()
        // Register cell classes
        self.collectionView!.register(StreakCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView?.register(StreakCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        showBadge = defaults.bool(forKey: "badgeOn")

        setupView()
        updateUI()
        
    }
    
    fileprivate func setupView() {
        collectionView?.backgroundColor = .white
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.clipsToBounds = true
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection =  .horizontal
        }
    }
    
    var onLaunch = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        
        if onLaunch && fetchedResultsController.sections![0].numberOfObjects > 0 {
            let currentIndex = IndexPath(item: 0, section: 0)
            collectionView?.scrollToItem(at: currentIndex,at: .left,animated: false)
            pageIndicator.currentPage = 1
            onLaunch = false
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func initializeFetchedResultsController() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

        let managedContext = appDelegate.persistentContainer.viewContext
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        let predicate = NSPredicate(format: "finishedStreak == false")
        
        let fetchRequest:NSFetchRequest<Streak> = Streak.fetchRequest()
        fetchRequest.sortDescriptors = [nameSort]
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    
    
    
    //UI:
    private func updateUI() {
        if let streaks = fetchedResultsController!.fetchedObjects {
            for streak in streaks {
                let log = OSLog(subsystem: "com.Oskman.Countdays", category: "updateUI")
                
                os_log(OSLogType.default,log: log, "Day:%{public}s", self.currentDay.description)
                os_log(OSLogType.default,log: log, "Start: %{public}s", (streak.start?.description)! )


                streak.count = Int64(differenceInDays(start: self.currentDay, end: streak.start ?? self.currentDay))
                os_log(OSLogType.default,log: log, "count: %{public}d", streak.count)
                
                if streak.badge == true  && showBadge {
                    UIApplication.shared.applicationIconBadgeNumber = Int(streak.count)
                    defaults.set(Int(streak.count), forKey: "currentCount")
                }
            }
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        if managedContext.hasChanges {
            try? managedContext.save()
        }
        
        pageIndicator.numberOfPages = fetchedResultsController.sections![0].numberOfObjects + 1

        collectionView?.reloadData()
    }
    
    let pageIndicator: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .lushGreenColor
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.hidesForSinglePage = true
        pageControl.addTarget(self, action: #selector(goToNextScreen), for: .valueChanged)
        pageControl.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        return pageControl
    }()
    
    @objc private func goToNextScreen() {
        print(pageIndicator.numberOfPages, "total")
        print(pageIndicator.currentPage,"currentpage")
        switch pageIndicator.currentPage {
        case 0:
            collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: view.safeAreaLayoutGuide.layoutFrame.width, height: view.safeAreaLayoutGuide.layoutFrame.height), animated: true)
//        case pageIndicator.numberOfPages - 1:
//            pageIndicator.currentPage = pageIndicator.currentPage - 1
        default:
            let currentIndex = IndexPath(item: pageIndicator.currentPage - 1, section: 0)
            collectionView?.scrollToItem(at: currentIndex,at: .left,animated: true)
        }
    }
    
    fileprivate func setupPaging() {
        let bottomStackView = UIStackView(arrangedSubviews: [pageIndicator])
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.alignment = .center
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        
        view.addSubview(bottomStackView)
        bottomStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bottomStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        bottomStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        bottomStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        pageIndicator.currentPage = Int(x / view.frame.width)
    }
    
    internal func showChangeNameAlert(_ cell: StreakCollectionViewCell) {
        nameAlert(indexPath: nil, cell: cell, editStreak: true)
    }
    internal func showChangeNameAlert(_ cell: StreakCollectionViewHeader) {
        nameAlert(indexPath: nil, cell: nil, editStreak: false)
    }
    
    private func nameAlert(indexPath: IndexPath?, cell: StreakCollectionViewCell?, editStreak: Bool){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        if !editStreak {
            alertController.title =  "New Streak"
            alertController.message = "Please name your new Streak"
        } else {
            alertController.title = "Edit Streak"
            alertController.message = "Please input new name for this Streak"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            if let path = indexPath {
                self.collectionView?.scrollToItem(at: path, at: .right, animated: true)
                self.pageIndicator.currentPage = (path.item) + 1
                self.updateUI()
                self.collectionView?.reloadData()
            }
        }
            
        
        let confirmAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let name = alertController.textFields?.first?.text {
//                self?.currentTitle = name.uppercased()
                if let cell = cell {

                    self?.fetchedResultsController.object(at: cell.currentIndexPath).name = name.uppercased()
                }  else {
                    let newStreak = Streak(context: managedContext)
                    newStreak.start = (self?.currentDay)!
                    newStreak.name = name.uppercased()
                }

                self?.updateUI()

                try? managedContext.save()
            }
        }
        confirmAction.isEnabled = false
        
        //adding textfields to our dialog box
        alertController.addTextField { textField in
            textField.placeholder = "Name"
            NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: textField, queue: .main) { notif in
                if let text = textField.text, !text.isEmpty {
                    confirmAction.isEnabled = true
                } else {
                    confirmAction.isEnabled = false
                }
            }
        }
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        //present Dialog
        self.present(alertController, animated: true, completion: nil)
    }
    internal func getDateAlert(_ cell: StreakCollectionViewCell) {
        let currentStreak = fetchedResultsController.object(at: cell.currentIndexPath)
        var components: DateComponents = DateComponents()
        components.calendar = calendar
        components.year = -135
        let minDate: Date = calendar.date(byAdding: components, to: currentDay)!
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.setDate(currentStreak.start!, animated: true)
        datePicker.maximumDate = currentDay
        datePicker.minimumDate = minDate
        
        let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        alert.isModalInPopover = true
        
        alert.view.addSubview(datePicker)
        alert.message = "Change the start day of the streak"
        let ok = UIAlertAction(title: "Enter", style: .default) { (action) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyy-MM-dd"
            currentStreak.start = self.changeToMidnight(toChange: datePicker.date)
            self.updateUI()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    internal func getGoalAlert(_ cell: StreakCollectionViewCell) {
        let currentStreak = fetchedResultsController.object(at: cell.currentIndexPath)


        let alert = UIAlertController(title: "Set a Goal for your Streak:", message: nil, preferredStyle: .actionSheet)
        alert.isModalInPopover = true
        
        let seven = UIAlertAction(title: "7 days", style: .default) { (action) in
            currentStreak.goal = 7
            self.updateUI()
        }
        let thirthy = UIAlertAction(title: "30 days", style: .default) { (action) in
            currentStreak.goal = 30
            self.updateUI()
        }
        let removeGoal = UIAlertAction(title: "remove current Goal", style: .destructive) { (action) in
            currentStreak.goal = 0
            self.updateUI()
        }
        print(currentStreak.goal)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(seven)
        alert.addAction(thirthy)
        alert.addAction(removeGoal)
        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }
    
    
    internal func restartStreak(_ cell: StreakCollectionViewCell) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let restartedStreak = fetchedResultsController.object(at: cell.currentIndexPath)
        let newStreak = Streak(context: managedContext)
        newStreak.start = restartedStreak.start
        newStreak.name = restartedStreak.name
        newStreak.count = restartedStreak.count
        newStreak.goal = restartedStreak.goal
        newStreak.end = currentDay
        newStreak.restartedStreak = true
        newStreak.finishedStreak = true
        try? managedContext.save()

        restartedStreak.start = currentDay
        restartedStreak.finishedStreak = false
        
        try? managedContext.save()
        
        updateUI()
    }
    
    internal func saveStreak(_ cell: StreakCollectionViewCell) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let currentStreak = fetchedResultsController.object(at: cell.currentIndexPath)
        currentStreak.end = currentDay
        currentStreak.finishedStreak = true
        currentStreak.badge = false
        defaults.removeObject(forKey: "currentCount")
        UIApplication.shared.applicationIconBadgeNumber = 0
        try? managedContext.save()
        updateUI()
        if Bool.random() {
            SKStoreReviewController.requestReview()
        }

    }
    
    internal func sequeToSaveScreen() {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
        self.navigationController?.pushViewController(SaveScreenViewController(), animated: true)
    }
    
    
    func newEmptyStreakButtonPressed(_ cell: StreakCollectionViewCell) {
        self.updateUI()
        collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: view.safeAreaLayoutGuide.layoutFrame.width, height: view.safeAreaLayoutGuide.layoutFrame.height), animated: false)
        pageIndicator.currentPage = 0
        nameAlert(indexPath: cell.currentIndexPath, cell: nil, editStreak: false)
    }
    

    /**
     Changes a date Value to midnight
     - Parameters:
     - toChange: the date that needs to be changed
     - Returns: the Date Value set to midnight
     */
    public func changeToMidnight(toChange: Date) -> Date {
        return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: toChange)!
    }
    
    /**
     Calculates the differece between a day and another day in days. Adds one to the value in order to count the first day aswell.
     - Parameters:
     - start: the beginning day
     - end: the end day
     - Returns: the difference between the two days as an Int
     */
    public func differenceInDays(start:Date,end:Date) -> Int {
        return Calendar.current.dateComponents([ .day], from: end , to: start).day! + 1
    }
    
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let unFinishedStreak = fetchedResultsController.object(at: indexPath )
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! StreakCollectionViewCell
        cell.delegate = self
        cell.streakNameButton.setTitle(unFinishedStreak.name, for: .normal)
        cell.streakNumberButton.setTitle(String(unFinishedStreak.count), for: .normal)
        switch unFinishedStreak.count {
        case 1:
            cell.roundDaysbutton.setTitle("Day", for: .normal)
        default:
            cell.roundDaysbutton.setTitle("Days", for: .normal)
        }
        if unFinishedStreak.goal != 0 {
            cell.progress = Float(unFinishedStreak.count) / Float(unFinishedStreak.goal)
        } else {
            cell.progress = 1
        }
        cell.updateUI()
        cell.currentIndexPath = indexPath
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var view = UICollectionReusableView()
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! StreakCollectionViewHeader
            header.delegate = self
            header.streakNameButton.setTitle("Start new Streak", for: .normal)
            header.updateUI()
            view = header
        }
//        } else if kind == UICollectionElementKindSectionFooter {
//            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "myFooterView", for: indexPath) as! StreakCollectionViewFooter
//            footer.delegate = self
//            footer.goToSaveScreen()
//            view = footer
//        }
        return view
    
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: (view.safeAreaLayoutGuide.layoutFrame.width), height: view.safeAreaLayoutGuide.layoutFrame.height);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.safeAreaLayoutGuide.layoutFrame.width), height: view.safeAreaLayoutGuide.layoutFrame.height);
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

@available(iOS 12.0, *)
extension StreakCollectionViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.reloadData()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.reloadData()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            collectionView?.reloadData()
        case .insert:
            collectionView?.scrollToItem(at: newIndexPath!, at: .right, animated: true)
            pageIndicator.currentPage = (newIndexPath?.item)! + 1
            self.updateUI()
            collectionView?.reloadData()
        case .delete:
            collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: view.safeAreaLayoutGuide.layoutFrame.width, height: view.safeAreaLayoutGuide.layoutFrame.height), animated: false)
            pageIndicator.currentPage = 0
            collectionView?.reloadData()
        default:
            break
        }
    }
}



