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



@available(iOS 12.0, *)

class StreakCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Properties
    let defaults = UserDefaults.standard
    
    let calendar = Calendar.current
    
    var currentDay = Calendar.current.startOfDay(for: Date())
    var applicattionDidLoadFromSuspended = false


    private let cellIdentifier = "Cell"
    private let headerId = "headerId"
    
    var onLaunch = true

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadUI), name: UIApplication.willEnterForegroundNotification, object: nil)

        setupPaging()
        // Register cell classes
        self.collectionView!.register(StreakCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView?.register(StreakCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        collectionView?.backgroundColor = .systemBackground
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.clipsToBounds = true
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection =  .horizontal
        }
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        StreakController.shared.unfinishedStreakfetchResultsController.delegate = self
        
        if onLaunch && StreakController.shared.unfinishedStreakfetchResultsController.sections![0].numberOfObjects > 0 {
            let currentIndex = IndexPath(item: 0, section: 0)
            collectionView?.scrollToItem(at: currentIndex,at: .left,animated: false)
            pageIndicator.currentPage = 1
            onLaunch = false
        }
        updateUI()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: - UIElements
    let pageIndicator: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .lushGreenColor
        pageControl.pageIndicatorTintColor = .systemGray3
        pageControl.hidesForSinglePage = true
        pageControl.addTarget(self, action: #selector(goToNextScreen), for: .valueChanged)
        pageControl.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        return pageControl
    }()
    
    func setupPaging() {
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
    
    //MARK: - updateUI
    private func updateUI() {
        StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?.forEach({ (streak) in
            streak.count = Int32(differenceInDays(start: self.currentDay, end: streak.start ?? self.currentDay))
            
            if streak.badge == true {
                UIApplication.shared.applicationIconBadgeNumber = Int(streak.count)
                defaults.set(Int(streak.count), forKey: "currentCount")
            }
        })
        
        pageIndicator.numberOfPages = StreakController.shared.unfinishedStreakfetchResultsController.sections![0].numberOfObjects + 1
    }
    
    //MARK: - Actions
    @objc private func goToNextScreen() {
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
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        pageIndicator.currentPage = Int(x / view.frame.width)
    }
    
    // MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StreakController.shared.unfinishedStreakfetchResultsController.sections?[section].numberOfObjects ?? 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let streak = StreakController.shared.unfinishedStreakfetchResultsController.object(at: indexPath)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? StreakCollectionViewCell else {return UICollectionViewCell()}
        cell.delegate = self
        
        cell.streakNameButton.setTitle(streak.name, for: .normal)
        cell.streakNumberButton.setTitle(String(streak.count), for: .normal)
        switch streak.count {
        case 1:
            cell.roundDaysbutton.setTitle(NSLocalizedString("Day", comment: "The ammount of days the streak has been active"), for: .normal)
        default:
            cell.roundDaysbutton.setTitle(NSLocalizedString("Days", comment: "The ammount of days the streak has been active"), for: .normal)
        }
        if streak.goal != 0 {
            cell.progress = Float(streak.count) / Float(streak.goal)
        } else {
            cell.progress = 1
        }
        cell.updateUI()
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var view = UICollectionReusableView()
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! StreakCollectionViewHeader
            header.delegate = self
            header.streakNameButton.setTitle(NSLocalizedString("Start new Streak", comment: "Call to action to start a new Streak"), for: .normal)
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
    
    //MARK: - Private Functions
    @objc func reloadUI() {
        let sharedUserDefaults = UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")!

        if sharedUserDefaults.bool(forKey: SharedUserDefaults.ContentStreakHasChanged) {
            collectionView?.reloadData()
            updateUI()
        }
    }
    
    private func nameAlert(cell: StreakCollectionViewCell?, editStreak: Bool){
        var nameTextField: UITextField?
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        if !editStreak {
            alertController.title =  NSLocalizedString("New Streak", comment: "Alert Title when a new Streak is started")
            alertController.message = NSLocalizedString("Please name your new Streak", comment: "Alert Subtitle when a new Streak is started")
        } else {
            alertController.title = NSLocalizedString("Edit Streak", comment: "Alert Title when a Streak is being renamed")
            alertController.message = NSLocalizedString("Please input new name for this Streak", comment: "Alert Subtitle when a streak is being renamed")
        }
        
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel the name Alert"), style: .cancel) { (action) in
            //            self.collectionView?.scrollToItem(at: index!, at: .right, animated: true)
            //            self.pageIndicator.currentPage = (index?.item)! + 1
            //            self.updateUI()
            //            self.collectionView?.reloadData()
        }
        
        let confirmAction = UIAlertAction(title: NSLocalizedString("Save", comment: "Save the name entered"), style: .default) { [weak self] action in
            if let name = nameTextField?.text {
                if editStreak {
                    //update
                    guard  let cell = cell, let index = self?.collectionView?.indexPath(for: cell) else {return}
                    let streak = StreakController.shared.unfinishedStreakfetchResultsController.object(at: index)
                    StreakController.shared.update(name: name, ofStreak: streak)
                } else {
                    //new Streak
                    StreakController.shared.createStreakWith(name: name)
                }
                
                self?.updateUI()
            }
        }
        confirmAction.isEnabled = false
        
        //adding textfields to our dialog box
        alertController.addTextField { [weak self] textField in
            switch editStreak {
            case true:
                guard  let cell = cell, let index = self?.collectionView?.indexPath(for: cell) else {return}
                let streak = StreakController.shared.unfinishedStreakfetchResultsController.object(at: index)
                textField.text = streak.name
                textField.placeholder = streak.name
                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                    if let name = textField.text, !name.isEmpty, name != streak.name {
                        confirmAction.isEnabled = true
                        nameTextField = textField
                    } else {
                        confirmAction.isEnabled = false
                    }
                }
            case false:
                textField.placeholder = NSLocalizedString("Add Name", comment: "PlaceholderText in the textfield to add or edit name of Streak")
                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                    
                    
                    if let name = textField.text, !name.isEmpty {
                        confirmAction.isEnabled = true
                        nameTextField = textField
                    } else {
                        confirmAction.isEnabled = false
                    }
                }
            }
        }
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        //present Dialog
        self.present(alertController, animated: true, completion: nil)
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
}
//MARK: - CollectionViewFooterDelegate
extension StreakCollectionViewController: CollectionViewFooterDelegate {

}
//MARK: - CollectionViewHeaderDelegate
extension StreakCollectionViewController: CollectionViewHeaderDelegate {
    func showChangeNameAlert(_ cell: StreakCollectionViewHeader) {
        nameAlert(cell: nil, editStreak: false)
    }
}
//MARK: - CollectionViewCellDelegate
extension StreakCollectionViewController: CollectionViewCellDelegate {
    func showChangeNameAlert(_ cell: StreakCollectionViewCell) {
        nameAlert(cell: cell, editStreak: true)
    }
    func getDateAlert(_ cell: StreakCollectionViewCell) {
        guard  let index = collectionView?.indexPath(for: cell) else {return}
        let streak = StreakController.shared.unfinishedStreakfetchResultsController.object(at: index)
        var components: DateComponents = DateComponents()
        components.calendar = calendar
        components.year = -135
        let minDate: Date = calendar.date(byAdding: components, to: currentDay)!
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.setDate(streak.start ?? currentDay, animated: true)
        datePicker.maximumDate = currentDay
        datePicker.minimumDate = minDate
        datePicker.locale = Locale.autoupdatingCurrent
        
        let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        alert.isModalInPopover = true
        
        alert.view.addSubview(datePicker)
        alert.message = NSLocalizedString("Change the start day of the streak", comment:"Change the start day of the streak")
        let okAction = UIAlertAction(title: NSLocalizedString("Save", comment: "Save the current change the start date"), style: .default) { (action) in

            StreakController.shared.update(startDate: datePicker.date, ofStreak: streak)
            self.updateUI()
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel the current time Selection"), style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    func getGoalAlert(_ cell: StreakCollectionViewCell) {
        guard  let index = collectionView?.indexPath(for: cell) else {return}
        
        let streak = StreakController.shared.unfinishedStreakfetchResultsController.object(at: index)
        
        let alert = UIAlertController(title: NSLocalizedString("Set a Goal for your Streak:", comment: "Alert Title to set goal of streak"), message: nil, preferredStyle: .actionSheet)
        alert.isModalInPopover = true
        
        let seven = UIAlertAction(title: NSLocalizedString("7 days", comment: "7 days"), style: .default) { (action) in
            StreakController.shared.add(goal: 7, ofStreak: streak)
            self.updateUI()
        }
        let thirthy = UIAlertAction(title: NSLocalizedString("30 days", comment: "30 days"), style: .default) { (action) in
            StreakController.shared.add(goal: 30, ofStreak: streak)
            self.updateUI()
        }
        let removeGoal = UIAlertAction(title: NSLocalizedString("remove current Goal", comment: "remove current Goal"), style: .destructive) { (action) in
            StreakController.shared.add(goal: 0, ofStreak: streak)
            self.updateUI()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel the goal selection"), style: .cancel, handler: nil)
        alert.addAction(seven)
        alert.addAction(thirthy)
        alert.addAction(removeGoal)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    func restartStreak(_ cell: StreakCollectionViewCell) {
        guard  let index = collectionView?.indexPath(for: cell) else {return}
        StreakController.shared.restart(streak: StreakController.shared.unfinishedStreakfetchResultsController.object(at: index))
        updateUI()
    }
    func saveStreak(_ cell: StreakCollectionViewCell) {
            guard  let index = collectionView?.indexPath(for: cell) else {return}
            if StreakController.shared.unfinishedStreakfetchResultsController.object(at: index).badge == true {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            StreakController.shared.finish(streak: StreakController.shared.unfinishedStreakfetchResultsController.object(at: index))
            updateUI()
            if Bool.random() {
                SKStoreReviewController.requestReview()
            }
    }
    func segueToSaveScreen() {
        let backItem = UIBarButtonItem()
        backItem.title = NSLocalizedString("Back", comment: "Back to Streak Collection")
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
        self.navigationController?.pushViewController(SaveScreenViewController(), animated: true)
    }
    func newEmptyStreakButtonPressed(_ cell: StreakCollectionViewCell) {
        self.updateUI()
        collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: view.safeAreaLayoutGuide.layoutFrame.width, height: view.safeAreaLayoutGuide.layoutFrame.height), animated: false)
        pageIndicator.currentPage = 0
        nameAlert(cell: cell, editStreak: false)
    }
    
}
//MARK: - NSFetchedResultsControllerDelegate
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
            guard let indexPath = indexPath else {return}
            //                collectionView?.reloadItems(at: [indexPath])
            collectionView?.reloadData()
        case .insert:
            guard let newIndexPath = newIndexPath else {return}
            collectionView?.reloadData()
            
//            collectionView?.insertItems(at: [newIndexPath])
            collectionView?.scrollToItem(at: newIndexPath, at: .right, animated: true)
            pageIndicator.currentPage = (newIndexPath.item) + 1
            self.updateUI()
        case .delete:
            guard let indexPath = indexPath else {return}
            //                collectionView?.deleteItems(at: [indexPath])
            collectionView?.reloadData()
            
            collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: view.safeAreaLayoutGuide.layoutFrame.width, height: view.safeAreaLayoutGuide.layoutFrame.height), animated: false)
            pageIndicator.currentPage = 0
        case .move:
            guard let newIndexPath = newIndexPath, let indexPath = indexPath else {return}
            //                collectionView?.moveItem(at: indexPath, to: newIndexPath)
            collectionView?.reloadData()
            
        }
    }
}



