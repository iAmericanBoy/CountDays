//
//  SaveScreenViewController.swift
//  CountDays
//
//  Created by Dominic Lanzillotta on 8/29/18.
//  Copyright © 2018 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import StoreKit


class SaveScreenViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    //MARK: - Properties
    var tableView = UITableView(frame: UIScreen.main.bounds)
    let cellId = "cellId"
    let headerId = "headerId"
    let footerId = "footerId"
    var lastSelectedRow = -1
    
    let defaults = UserDefaults.standard
    
    var sortBy: NSSortDescriptor {
        get {
            return NSSortDescriptor(key: defaults.string(forKey: "sortBy") ?? "name", ascending: false)
        }
        set (newSortDescriptor){
            defaults.set(newSortDescriptor.key, forKey: "sortBy")
        }
    }
    

    
    var selectedStreak = -1
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        streakPicker.dataSource = self
        streakPicker.delegate = self
        StreakController.shared.finishedStreakfetchResultsController.delegate = self

        for (n, streak) in (StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?.enumerated())! {
            if streak.badge {
                selectedStreak = n
            }
        }


            
        self.view.backgroundColor = .white
            
        tableView.register(StreakCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        setupUI()
        
        tableView.reloadData()
        updateEditButtonState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // hide the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if badgeSwitch.isOn && StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects!.count > 0 && lastSelectedRow != -1 {
            StreakController.shared.toggle(badge: true, ofStreak: StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects![lastSelectedRow])
            
        }
    }
    
    //MARK: - UIElements
    lazy var sortButton = UIBarButtonItem(title: "Sort", style: UIBarButtonItemStyle.plain, target: self, action: #selector(sortList))
    
    lazy var tap = UITapGestureRecognizer(target: self, action: #selector(streakPickerDismissed))
    
    let badgeSwitch:UISwitch = {
        let newSwitch = UISwitch()
        newSwitch.isOn = false
        newSwitch.addTarget(self, action: #selector(switchAction), for: .valueChanged)
        newSwitch.translatesAutoresizingMaskIntoConstraints = false
        newSwitch.backgroundColor = .white
        newSwitch.layer.cornerRadius = newSwitch.frame.height / 2
        newSwitch.onTintColor = UIColor(red: (62/255),green: (168/255),blue: (59/255),alpha:0.9)
        return newSwitch
    }()
    
    let badgeLabel: UILabel = {
        let label = UILabel()
        label.text = "Display the amount of days on the badge"
        label.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
        label.textAlignment = .natural
        label.numberOfLines = 0;
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let badgeSelectionTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: " Select a Streak...",
                                                             attributes: [.font:UIFont.systemFont(ofSize: UIFont.buttonFontSize), NSAttributedString.Key.foregroundColor: UIColor.systemBlue])
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        return textField
    }()
    let badgePlaceholderButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
        button.isEnabled = false
        button.layer.borderColor = UIColor.clear.cgColor
        return button
    }()
    
    let reminderSwitch:UISwitch = {
        let newSwitch = UISwitch()
        newSwitch.isOn = false
        newSwitch.addTarget(self, action: #selector(turnOnReminder), for: .valueChanged)
        newSwitch.translatesAutoresizingMaskIntoConstraints = false
        newSwitch.backgroundColor = .white
        newSwitch.layer.cornerRadius = newSwitch.frame.height / 2
        newSwitch.onTintColor = UIColor(red: (62/255),green: (168/255),blue: (59/255),alpha:0.9)
        newSwitch.isOn = false
        return newSwitch
    }()
    
    let reminderLabel: UILabel = {
        let label = UILabel()
        label.text = "Send daily reminder"
        label.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
        label.textAlignment = .natural
        label.numberOfLines = 0;
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let reminderSelectionTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: " Select a Streak...",
                                                             attributes: [.font:UIFont.systemFont(ofSize: UIFont.buttonFontSize), NSAttributedString.Key.foregroundColor: UIColor.systemBlue])
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        return textField
    }()
    
    let reminderDefaultButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change default Text", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.addTarget(self, action: #selector(reminderDefaultButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let streakPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let aboutTextView: UITextView = {
        let textField =  UITextView()
        textField.isEditable = false
        textField.isUserInteractionEnabled = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .clear
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attributedString = NSMutableAttributedString(string: "DaysInARow is made by Dominic Lanzillotta \n in Chicago", attributes: [.paragraphStyle: paragraph,.font:UIFont.systemFont(ofSize: 17)])
        let url = URL(string: "https://www.twitter.com/iAmericanBoy")!
        
        // Set the 'click here' substring to be the link
        attributedString.setAttributes([.link: url, .font: UIFont.systemFont(ofSize: UIFont.buttonFontSize)], range: NSMakeRange(22, 20))
        
        textField.attributedText = attributedString
        
        return textField
    }()
    
    let reviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Please Rate DaysInARow", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(reviewApp), for: .touchUpInside)
        button.setTitleColor(button.currentTitleColor.withAlphaComponent(0.8), for: .normal)
        return button
    }()
    
    //MARK: - SetupView
    private func setupUI() {
        self.navigationController?.navigationBar.topItem?.title = "Past Streaks"
        self.navigationController?.navigationBar.topItem?.rightBarButtonItems = [self.editButtonItem, sortButton]
        
        self.view.addSubview(self.tableView)
        self.view.addGestureRecognizer(tap)
        self.tableView.addGestureRecognizer(tap)
        
        tableView.backgroundColor = UIColor(red: (62/255),green: (168/255),blue: (59/255),alpha:0.9)
        tableView.rowHeight = 55
        
        let footerHeight: CGFloat =  500
        tableView.allowsSelection = false
        tableView.sectionFooterHeight = footerHeight
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: footerHeight))
        
        tableView.tableFooterView?.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let badgeStackView = UIStackView(arrangedSubviews: [badgeLabel,badgeSwitch])
        badgeStackView.alignment = .center
        badgeStackView.distribution = .equalSpacing
        badgeStackView.axis = .horizontal
        
        let badgeSettingsStackView = UIStackView(arrangedSubviews: [badgeSelectionTextField, badgePlaceholderButton])
        badgeSettingsStackView.alignment = .fill
        badgeSettingsStackView.distribution = .fillEqually
        badgeSettingsStackView.axis = .horizontal
        badgeSettingsStackView.spacing = 5
        
        let reminderStackView = UIStackView(arrangedSubviews: [reminderLabel, reminderSwitch])
        reminderStackView.alignment = .center
        reminderStackView.distribution = .equalSpacing
        reminderStackView.axis = .horizontal
        
        let reminderSettingsStackView = UIStackView(arrangedSubviews: [reminderSelectionTextField, reminderDefaultButton])
        reminderSettingsStackView.alignment = .fill
        reminderSettingsStackView.distribution = .fillEqually
        reminderSettingsStackView.axis = .horizontal
        reminderSettingsStackView.spacing = 5
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let toolBar = UIToolbar()
        toolBar.setItems([space,doneButton], animated: true)
        toolBar.sizeToFit()
        
        
        badgeSelectionTextField.inputView = streakPicker
        badgeSelectionTextField.inputAccessoryView = toolBar
        reminderSelectionTextField.inputView = streakPicker
        reminderSelectionTextField.inputAccessoryView = toolBar

        
        let tableViewFooterStackView = UIStackView(arrangedSubviews: [badgeStackView,badgeSettingsStackView, reminderStackView, reminderSettingsStackView,aboutTextView, reviewButton])
        tableViewFooterStackView.alignment = .fill
        tableViewFooterStackView.distribution = .fill
        tableViewFooterStackView.axis = .vertical
        tableViewFooterStackView.spacing = 5
        tableViewFooterStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        tableView.tableFooterView?.addSubview(tableViewFooterStackView)
        tableViewFooterStackView.leadingAnchor.constraint(equalTo: tableView.tableFooterView!.layoutMarginsGuide.leadingAnchor).isActive = true
        tableViewFooterStackView.trailingAnchor.constraint(equalTo: tableView.tableFooterView!.layoutMarginsGuide.trailingAnchor).isActive = true
        tableViewFooterStackView.topAnchor.constraint(equalTo: tableView.tableFooterView!.layoutMarginsGuide.topAnchor).isActive = true
        tableViewFooterStackView.bottomAnchor.constraint(equalTo: tableView.tableFooterView!.layoutMarginsGuide.bottomAnchor).isActive = true
        
        
        reminderSwitch.isEnabled = selectedStreak < 0 ? false : true
        
        streakPicker.selectRow(selectedStreak + 1, inComponent: 0, animated: true)
        badgeSwitch.isOn = defaults.object(forKey: "badgeOn") as? Bool ?? false
        reminderSwitch.isOn = defaults.object(forKey: "dailyReminderOn") as? Bool ?? false
        
        if StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?.count == 0 {
            streakPicker.isHidden = true
        } else {
            streakPicker.isHidden = !badgeSwitch.isOn
        }
    }
    //MARK: - Actions:
    @objc func switchAction(sender: UISwitch!) {
        askForNotificationPermission()
        defaults.set(sender.isOn, forKey: "badgeOn")
        streakPicker.isHidden = !sender.isOn
        reminderSwitch.isHidden = !sender.isOn
        reminderLabel.isHidden = !sender.isOn
        streakPicker.selectRow(0, inComponent: 0, animated: true)
        if !sender.isOn {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    @objc func turnOnReminder() {
        defaults.set(reminderSwitch.isOn, forKey: "dailyReminderOn")
        guard 0 < streakPicker.selectedRow(inComponent: 0) else {return}
        
        if reminderSwitch.isOn {
            print("daily reminder sent")
            scheduleReminderNotification(name: StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?[streakPicker.selectedRow(inComponent: 0) - 1].name ?? "")

        } else {
            print("daily reminder turn off")
            
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ["DailyReminder"])
        }
    }
    
    @objc func sortList() {
        let alert = UIAlertController(title: "Sort your saved Streaks by:", message: nil, preferredStyle: .actionSheet)
        alert.isModalInPopover = true
        
        let count = UIAlertAction(title: "Streak Lenght", style: .default) { (action) in
            self.sortBy = NSSortDescriptor(key: "count", ascending: false)
            self.tableView.reloadData()
        }
        let startDate = UIAlertAction(title: "Streak Start Day", style: .default) { (action) in
            self.sortBy = NSSortDescriptor(key: "start", ascending: false)
            self.tableView.reloadData()
        }
        let restartedStreak = UIAlertAction(title: "Restarted Streak", style: .default) { (action) in
            self.sortBy = NSSortDescriptor(key: "restartedStreak", ascending: false)
            self.tableView.reloadData()
        }
        let streakName = UIAlertAction(title: "Streak Name", style: .default) { (action) in
            self.sortBy = NSSortDescriptor(key: "name", ascending: false)
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(count)
        alert.addAction(startDate)
        alert.addAction(restartedStreak)
        alert.addAction(streakName)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func reviewApp(sender: UIButton) {
        SKStoreReviewController.requestReview()
    }
    
    @objc func reminderDefaultButtonTapped() {
        
    }
    
    @objc func doneButtonTapped() {
        badgeSelectionTextField.resignFirstResponder()
        reminderSelectionTextField.resignFirstResponder()
    }
    
    @objc func streakPickerDismissed(){
        badgeSelectionTextField.resignFirstResponder()
        reminderSelectionTextField.resignFirstResponder()
    }
    //MARK: - Notifications
    private func askForNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (granted, error) in
            if let error = error {
                print("granted, but Error in notification permission:\(error.localizedDescription)")
            }
        }
    }
    
    func scheduleReminderNotification(name: String) {
        let restartAction = UNNotificationAction(identifier: "Restart", title: "Restart Streak", options: [.destructive])
        let finishAction = UNNotificationAction(identifier: "Finish", title: "Finish Streak", options: [.destructive])
        
        let category = UNNotificationCategory(identifier: "DailyReminderCategory", actions: [restartAction, finishAction],intentIdentifiers: [], options: [])
        
        let content = UNMutableNotificationContent()
        content.body = "Did you continue your streak of \(name)?"
        content.title = "Daily Streak: \(name)"
        content.categoryIdentifier = "DailyReminderCategory"
        
        //Real
        //         Configure the trigger for notification at 4
        var triggerDate = DateComponents()
        triggerDate.hour = 16
        
        //Test
        // Configure the trigger for notification at 3 seconds
        //        var triggerDate = DateComponents()
        //        triggerDate.second = 3
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        // Create the request object.
        let request = UNNotificationRequest(identifier: "DailyReminder", content: content, trigger: trigger)
        
        // Schedule the request.
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([category])
        center.removePendingNotificationRequests(withIdentifiers: ["DailyReminder"])
        
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    //MARK: - Private Functions
    func updateEditButtonState() {
        if let numberOfObjects = StreakController.shared.finishedStreakfetchResultsController.sections?[0].numberOfObjects {
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem?.isEnabled = numberOfObjects > 0
        }
    }
    ///this function sets all the badge boolean values of the unfinished streak to false
    func resetBadge() {

        StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?.forEach({ (streak) in
            StreakController.shared.toggle(badge: false, ofStreak: streak)
        })

    }
}

//MARK: - NSFetchedResultsControllerDelegate:
extension SaveScreenViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else {return}
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let newIndexPath = newIndexPath, let indexPath = indexPath else {return}
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else {return}
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type{
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default:
            break
        }
    }
}

//MARK: - TableViewDataSource:
extension SaveScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let number = StreakController.shared.finishedStreakfetchResultsController.sections?[section].numberOfObjects ?? 0
        return number
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return StreakController.shared.finishedStreakfetchResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let streak =  StreakController.shared.finishedStreakfetchResultsController.object(at: indexPath )
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! StreakCell
        cell.streakLabel.text = streak.name
        cell.streakNumberLabel.text = streak.count.description
        cell.unFinishedStreak = streak.restartedStreak
        if streak.goal != 0 {
            cell.progressRatio = Float(streak.count) / Float(streak.goal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            StreakController.shared.remove(streak: StreakController.shared.finishedStreakfetchResultsController.object(at: indexPath))
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        self.tableView.setEditing(editing, animated: true)
    }
}

//MARK: - PickerView:
extension SaveScreenViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?.count ?? 0) + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var streakLabel = "SELECT A STREAK"
        if StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?.count == 0 {
            streakLabel = "no current Streak available"
        }
        if row != 0 {
            streakLabel = StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?[row - 1].name ?? "empty"
        }
        return streakLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        resetBadge()
        
        if row > 0 {
            //"a streak was selected"
            UIApplication.shared.applicationIconBadgeNumber = Int(truncating: StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?[row - 1].count as! NSNumber)
            
            lastSelectedRow = row - 1
            reminderSwitch.isEnabled = true
            reminderSwitch.isOn = false
        } else {
            //"select a row was selected"
            lastSelectedRow = -1
            UIApplication.shared.applicationIconBadgeNumber = 0
            reminderSwitch.setOn(false, animated: true)
            reminderSwitch.isEnabled = false
            turnOnReminder()
        }
    }
}
