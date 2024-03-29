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
    
    let defaults = UserDefaults.standard
    
    var sortBy: NSSortDescriptor {
        get {
            return NSSortDescriptor(key: defaults.string(forKey: "sortBy") ?? "name", ascending: false)
        }
        set (newSortDescriptor){
            defaults.set(newSortDescriptor.key, forKey: "sortBy")
            StreakController.shared.finishedStreakfetchResultsController.fetchRequest.sortDescriptors = [newSortDescriptor]
            try? StreakController.shared.finishedStreakfetchResultsController.performFetch()

        }
    }
    
    //MARK: - LifeCycle

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadUI), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        tableView.dataSource = self
        
        badgeStreakPicker.dataSource = self
        badgeStreakPicker.delegate = self
        reminderStreakPicker.dataSource = self
        reminderStreakPicker.delegate = self
        
        reminderTimeDefaultTextField.delegate = self
        reminderSelectionTextField.delegate = self
        badgeSelectionTextField.delegate = self
        


        StreakController.shared.finishedStreakfetchResultsController.delegate = self

        setpickerViewValue()

        self.view.backgroundColor = .systemBackground
            
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
        

    }
    
    //MARK: - UIElements
    lazy var sortButton = UIBarButtonItem(title: NSLocalizedString("Sort", comment: "Label to sort the saved Streaks"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(sortList))
    
    lazy var tap = UITapGestureRecognizer(target: self, action: #selector(userTappedOnView))
    
    let settingSwitch:UISwitch = {
        let newSwitch = UISwitch()
        newSwitch.isOn = false
        newSwitch.addTarget(self, action: #selector(badgeSwitchToggled), for: .valueChanged)
        newSwitch.translatesAutoresizingMaskIntoConstraints = false
        newSwitch.backgroundColor = .systemBackground
        newSwitch.layer.cornerRadius = newSwitch.frame.height / 2
        newSwitch.onTintColor = .lushGreenColor.withAlphaComponent(0.9)
        return newSwitch
    }()
    
    let settingsLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Configure Notifications", comment: "Text in settings to configure Notifications in DaysInARow")
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let badgeLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Set badge for Streak:", comment: "Text in settings to set badge for streak")
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.isHidden = true
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let badgeSelectionTextField: TextFieldWithoutCopy = {
        let textField = TextFieldWithoutCopy()
        textField.attributedPlaceholder = NSAttributedString(string: " ",
                                                             attributes: [.font:UIFont.preferredFont(forTextStyle: .title1),
                                                                          .foregroundColor: UIColor.systemBlue])
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.tintColor = UIColor.systemFill
        textField.textColor = .systemBlue
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = true
        textField.text = NSLocalizedString("Select a Streak", comment: "Placeholdertext for the badgeSelectionTextFiled")
        return textField
    }()
    
    let reminderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Schedule reminder for Streak:", comment: "Text in settings to to set reminder for streak")
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .natural
        label.numberOfLines = 0;
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let reminderSelectionTextField: TextFieldWithoutCopy = {
        let textField = TextFieldWithoutCopy()
        textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Select a Streak", comment: "Placeholdertext for the reminderSelectionTextField"),
                                                             attributes: [.font:UIFont.preferredFont(forTextStyle: .title1),
                                                                          .foregroundColor: UIColor.systemBlue])
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.tintColor = UIColor.clear
        textField.textColor = .systemBlue
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = true

        textField.font = UIFont.preferredFont(forTextStyle: .body)
        return textField
    }()
    
    let reminderTextDefaultButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Text", for: .normal)
        button.setTitleColor(UIColor.systemGray, for: .disabled)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.addTarget(self, action: #selector(reminderDefaultTextButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let reminderTimeDefaultTextField: TextFieldWithoutCopy = {
        let textField = TextFieldWithoutCopy()
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.timeStyle = .short
        let fourPM = Calendar.current.date(bySetting: .hour, value: 16, of: Date())
        let timeString = dateFormatter.string(from: fourPM ?? Date())
        
        textField.attributedPlaceholder = NSAttributedString(string: timeString,
                                                             attributes: [.font:UIFont.preferredFont(forTextStyle: .title1),
                                                                          .foregroundColor: UIColor.systemGray])
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.tintColor = UIColor.systemFill
        textField.textColor = .systemBlue
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = true
        textField.isEnabled = false
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        return textField
    }()
    
    let badgeStreakPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.tag = 1111
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let reminderStreakPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.tag = 2222
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let timeStreakPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.tag = 3333
        picker.datePickerMode = UIDatePicker.Mode.time
        picker.translatesAutoresizingMaskIntoConstraints = false
        var fourPM = Calendar.current.date(bySetting: .hour, value: 16, of: Date())
        picker.date = fourPM!
        return picker
    }()
    
    let aboutTextView: UITextView = {
        let textField =  UITextView()
        textField.isEditable = false
        textField.isUserInteractionEnabled = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .clear
        textField.textColor = .label
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        let myName = "Dominic Lanzillotta"
        
        let attributedString = NSMutableAttributedString(string: NSLocalizedString("DaysInARow is made by Dominic Lanzillotta in Grand Rapids.", comment: "Label to tell who the App is made by. Dont change Dominic Lanzillotta and the new line carret"), attributes: [.paragraphStyle: paragraph, .font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: UIColor.label])
        let url = URL(string: "https://www.twitter.com/iAmericanBoy")!

        // Set the 'click here' substring to be the link
        attributedString.setAttributes([.link: url, .font: UIFont.preferredFont(forTextStyle: .body)], range: NSRange(attributedString.string.range(of: myName)!, in: attributedString.string))

        textField.attributedText = attributedString
        
        return textField
    }()
    
    let reviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Please Rate DaysInARow", comment: "Label to ask for an appstore Rating"), for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(reviewApp), for: .touchUpInside)
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    //MARK: - SetupView
    private func setupUI() {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Past Streaks", comment: "Title on the SaveScreen")
        self.navigationController?.navigationBar.topItem?.rightBarButtonItems = [self.editButtonItem, sortButton]
        
        self.view.addSubview(self.tableView)
        tableView.addGestureRecognizer(tap)

        
        tableView.backgroundColor = .lushGreenColor.withAlphaComponent(0.9)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        let footerHeight: CGFloat =  600
        tableView.allowsSelection = false
        tableView.sectionFooterHeight = footerHeight
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: footerHeight))

        tableView.tableFooterView?.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let settingsStackView = UIStackView(arrangedSubviews: [settingsLabel,settingSwitch])
        settingsStackView.alignment = .center
        settingsStackView.distribution = .fill
        settingsStackView.spacing = 5
        settingsStackView.axis = .horizontal
        
        let badgeStackView = UIStackView(arrangedSubviews: [badgeLabel])
        badgeStackView.alignment = .center
        badgeStackView.distribution = .equalSpacing
        badgeStackView.axis = .horizontal
        
        let badgeSettingsStackView = UIStackView(arrangedSubviews: [badgeSelectionTextField])
        badgeSettingsStackView.alignment = .fill
        badgeSettingsStackView.distribution = .fill
        badgeSettingsStackView.axis = .horizontal
        badgeSettingsStackView.spacing = 5
        
        
        let reminderStackView = UIStackView(arrangedSubviews: [reminderLabel])
        reminderStackView.alignment = .center
        reminderStackView.distribution = .equalSpacing
        reminderStackView.axis = .horizontal
        
        let reminderSettingsStackView = UIStackView(arrangedSubviews: [reminderSelectionTextField, reminderTextDefaultButton, reminderTimeDefaultTextField])
        reminderSettingsStackView.alignment = .fill
        reminderSettingsStackView.distribution = .fillProportionally
        reminderSettingsStackView.axis = .horizontal
        reminderSettingsStackView.spacing = 5
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let toolBar = UIToolbar()
        toolBar.setItems([space,doneButton], animated: true)
        toolBar.sizeToFit()
        
        
        badgeSelectionTextField.inputView = badgeStreakPicker
        badgeSelectionTextField.inputAccessoryView = toolBar
        reminderSelectionTextField.inputView = reminderStreakPicker
        reminderSelectionTextField.inputAccessoryView = toolBar
        reminderTimeDefaultTextField.inputView = timeStreakPicker
        reminderTimeDefaultTextField.inputAccessoryView = toolBar

        
        let tableViewFooterStackView = UIStackView(arrangedSubviews: [settingsStackView,badgeStackView,badgeSettingsStackView, reminderStackView, reminderSettingsStackView,aboutTextView, reviewButton])
        tableViewFooterStackView.alignment = .fill
        tableViewFooterStackView.distribution = .fill
        tableViewFooterStackView.axis = .vertical
        tableViewFooterStackView.spacing = 10
        tableViewFooterStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        tableView.tableFooterView?.addSubview(tableViewFooterStackView)
        tableViewFooterStackView.leadingAnchor.constraint(equalTo: tableView.tableFooterView!.layoutMarginsGuide.leadingAnchor).isActive = true
        tableViewFooterStackView.trailingAnchor.constraint(equalTo: tableView.tableFooterView!.layoutMarginsGuide.trailingAnchor).isActive = true
        tableViewFooterStackView.topAnchor.constraint(equalTo: tableView.tableFooterView!.layoutMarginsGuide.topAnchor).isActive = true
        tableViewFooterStackView.bottomAnchor.constraint(equalTo: tableView.tableFooterView!.layoutMarginsGuide.bottomAnchor).isActive = true
        settingsLabel.widthAnchor.constraint(equalTo: tableView.tableFooterView!.layoutMarginsGuide.widthAnchor, multiplier: 0.85).isActive = true

        setupStateofUI()
    }
    //MARK: - Actions:
    @objc func badgeSwitchToggled(sender: UISwitch!) {
        askForNotificationPermission()
        defaults.set(sender.isOn, forKey: "badgeOn")
        badgeStreakPicker.selectRow(0, inComponent: 0, animated: false)
        badgeSelectionTextField.text = NSLocalizedString("Select a Streak", comment: "Placeholdertext for the badgeSelectionTextFiled")


        reminderStreakPicker.selectRow(0, inComponent: 0, animated: false)
        reminderSelectionTextField.text = ""
        reminderTimeDefaultTextField.text = ""
        reminderTimeDefaultTextField.isEnabled = false
        reminderTextDefaultButton.isEnabled = false
        
        setupStateofUI()
        resetPickerSelections()
    }
    


    @objc func sortList() {
        let alert = UIAlertController(title: NSLocalizedString("Sort your saved Streaks by:", comment: "Label in Sort Alert"), message: nil, preferredStyle: .actionSheet)
        alert.isModalInPopover = true
        
        let count = UIAlertAction(title: NSLocalizedString("Streak Length", comment: "Sort by length of streak"), style: .default) { (action) in
            self.sortBy = NSSortDescriptor(key: "count", ascending: false)
            self.tableView.reloadData()
        }
        let startDate = UIAlertAction(title: NSLocalizedString("Streak Start Day", comment: "Sort by start of streak"), style: .default) { (action) in
            self.sortBy = NSSortDescriptor(key: "start", ascending: false)
            self.tableView.reloadData()
        }
        let restartedStreak = UIAlertAction(title: NSLocalizedString("Restarted Streak", comment: "Sort by restarted Streaks"), style: .default) { (action) in
            self.sortBy = NSSortDescriptor(key: "restartedStreak", ascending: false)
            self.tableView.reloadData()
        }
        let streakName = UIAlertAction(title: NSLocalizedString("Streak Name", comment: "Sort by name"), style: .default) { (action) in
            self.sortBy = NSSortDescriptor(key: "name", ascending: false)
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Sorting"), style: .cancel, handler: nil)
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
    
    @objc func reminderDefaultTextButtonTapped() {
        changeDefaultTextAlert(forRow: reminderStreakPicker.selectedRow(inComponent: 0) - 1)
    }
    
    @objc func doneButtonTapped() {
        userDissmissedPickerView()
    }
    
    @objc func userTappedOnView(){
        userDissmissedPickerView()
    }
    
    //MARK: - Notifications
    private func askForNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge, .providesAppNotificationSettings]) { (granted, error) in
            if let error = error {
                print("granted, but Error in notification permission:\(error.localizedDescription)")
            }
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.providesAppNotificationSettings]) { (granted, error) in
            if let error = error {
                print("granted, but Error in notification permission:\(error.localizedDescription)")
            }
        }
    }
    
    func scheduleReminderNotification(streak: Streak) {
        askForNotificationPermission()
        guard let name = streak.name, let startDate = streak.start else {return}
        
        if streak.uuid == nil {
            StreakController.shared.addUUID(toStreak: streak)
        }
        guard let uuid = streak.uuid?.uuidString else {return}

        let continueAction = UNNotificationAction(identifier: "continue", title: NSLocalizedString("Continue Streak", comment: "Notification Action title to continue streak"), options: UNNotificationActionOptions(rawValue: 0))
        let snoozeAction = UNNotificationAction(identifier: "snooze", title: NSLocalizedString("Ask me again in 1 hour", comment: "Notification action title to snooze notification"), options: UNNotificationActionOptions(rawValue: 0))

        
        let category = UNNotificationCategory(identifier: "DailyReminderCategory", actions: [continueAction,snoozeAction],intentIdentifiers: [], options: [])
        let content = UNMutableNotificationContent()
        if let body = streak.reminderText {
            content.body = body
        } else {
            content.body =  String.localizedStringWithFormat(
                NSLocalizedString("Did you continue your streak of %@?", comment: "Default Text in notification"), name)
        }

        content.title = String.localizedStringWithFormat(
            NSLocalizedString("Daily Streak: %@", comment: "Title for notification"),name)
        content.categoryIdentifier = "DailyReminderCategory"
        content.userInfo = [UserInfoDictionary.name:name,
                            UserInfoDictionary.start:startDate,
                            UserInfoDictionary.goal:streak.goal,
                            UserInfoDictionary.uuid:uuid]
        
        //Real
        //         Configure the trigger for notification at 4 or at different userselected time
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: timeStreakPicker.date)
        
        //Test
        // Configure the trigger for notification at 3 seconds
//                var triggerDate = DateComponents()
//                triggerDate.second = 3
        
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
            print("Added new notification with name:\(content.title), body: \(content.body) and userInfo: \(content.userInfo). Scheduled time: \(String(describing: request.trigger))")
        }
    }
    
    //MARK: - Private Functions
    func  displayHourAndMinute(forDate date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from:date)
    }
    
    @objc func reloadUI() {
        let sharedUserDefaults = UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")!

        if sharedUserDefaults.bool(forKey: SharedUserDefaults.ContentStreakHasChanged) {
            tableView.reloadData()
            badgeStreakPicker.selectRow(0, inComponent: 0, animated: true)
            badgeSelectionTextField.text = ""
            reminderStreakPicker.selectRow(0, inComponent: 0, animated: true)
            reminderSelectionTextField.text = ""
            reminderTextDefaultButton.isEnabled = false
            reminderTimeDefaultTextField.isEnabled = false
            
            reminderTimeDefaultTextField.text = nil
            timeStreakPicker.date = Calendar.current.date(bySetting: .hour, value: 16, of: Date())!
            
            setpickerViewValue()
            sharedUserDefaults.set(false, forKey: SharedUserDefaults.ContentStreakHasChanged) 
        }
    }
    
    func setpickerViewValue() {
        for (n, streak) in (StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?.enumerated())! {
            if streak.badge {
                badgeStreakPicker.selectRow(n + 1, inComponent: 0, animated: true)
                badgeSelectionTextField.text = streak.name
            }
            if streak.dailyReminder {
                reminderStreakPicker.selectRow(n + 1, inComponent: 0, animated: true)
                reminderSelectionTextField.text = streak.name
                reminderTextDefaultButton.isEnabled = true
                reminderTimeDefaultTextField.isEnabled = true
                var fourPM = Calendar.current.date(bySetting: .hour, value: 16, of: Date())
                fourPM = Calendar.current.date(bySetting: .minute, value: 0, of: fourPM!)
                reminderTimeDefaultTextField.text = displayHourAndMinute(forDate: streak.reminderTime ?? fourPM!)
                timeStreakPicker.date = streak.reminderTime ?? fourPM!
            }
        }
    }
    
    func updateEditButtonState() {
        if let numberOfObjects = StreakController.shared.finishedStreakfetchResultsController.sections?[0].numberOfObjects {
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem?.isEnabled = numberOfObjects > 0
        }
    }
    
    ///this function sets all the badge and daily reminder boolean values of the unfinished streak to false
    func resetPickerSelections() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["DailyReminder"])
        self.defaults.removeObject(forKey: "ReminderText")
        
//        let fourPM = Calendar.current.date(bySetting: .hour, value: 16, of: Date())
//        timeStreakPicker.date = fourPM!
//        reminderTimeDefaultTextField.text = displayHourAndMinute(forDate: timeStreakPicker.date)
        
        
        StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?.forEach({ (streak) in
            StreakController.shared.toggle(badge: false, ofStreak: streak)
        })
        StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?.forEach({ (streak) in
            StreakController.shared.toggle(reminder: false, ofStreak: streak)
        })
    }
    
    func setupStateofUI() {
        settingSwitch.isOn = defaults.object(forKey: "badgeOn") as? Bool ?? false
        tap.isEnabled = false
        

        
        if !settingSwitch.isOn {
                //button off w/o Streaks
                badgeLabel.isHidden = true
                badgeSelectionTextField.isHidden = true
                
                reminderLabel.isHidden = true
                reminderSelectionTextField.isHidden = true
                reminderTextDefaultButton.isHidden = true
                reminderTimeDefaultTextField.isHidden = true
            
                //button off w Streaks
                UIApplication.shared.applicationIconBadgeNumber = 0
                print("daily reminder turn off")
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: ["DailyReminder"])
                self.defaults.removeObject(forKey: "ReminderText")
                resetPickerSelections()
        } else {
            if StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?.count == 0 {
                //button on w/o Streak
                badgeSelectionTextField.isEnabled = false
                badgeSelectionTextField.isHidden = false
                badgeLabel.isHidden = false
                badgeSelectionTextField.text = NSLocalizedString("No active Steak", comment: "Text when no active streak is availabe for selection")
                badgeSelectionTextField.textColor = UIColor.systemGray
                
                reminderSelectionTextField.isEnabled = false
                reminderSelectionTextField.isHidden = false
                reminderTextDefaultButton.isHidden = false
                reminderTextDefaultButton.setTitleColor(UIColor.systemGray, for: .disabled)
                reminderTimeDefaultTextField.isEnabled = false
                reminderTimeDefaultTextField.isHidden = false
                reminderTimeDefaultTextField.text = ""

                reminderLabel.isHidden = false
                reminderSelectionTextField.text = NSLocalizedString("No active Steak", comment: "Text when no active streak is availabe for selection")
                reminderSelectionTextField.textColor = UIColor.systemGray

            } else {
                //button on w Streak
                badgeLabel.isHidden = false
                reminderLabel.isHidden = false

                reminderTextDefaultButton.isHidden = false
//                reminderTextDefaultButton.isEnabled = false


                reminderTimeDefaultTextField.isHidden = false
//                reminderTimeDefaultTextField.text = ""

                reminderSelectionTextField.isHidden = false
//                reminderSelectionTextField.text = ""
                
                badgeSelectionTextField.isHidden = false
//                badgeSelectionTextField.text = ""


            }
        }
    }

    func userDissmissedPickerView() {
        badgeSelectionTextField.resignFirstResponder()
        reminderSelectionTextField.resignFirstResponder()
        reminderTimeDefaultTextField.resignFirstResponder()
        

        if badgeStreakPicker.selectedRow(inComponent: 0) > 0 {
            let row = badgeStreakPicker.selectedRow(inComponent: 0) - 1
            UIApplication.shared.applicationIconBadgeNumber = Int(truncating: StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?[row].count as! NSNumber)
            StreakController.shared.toggle(badge: true, ofStreak: StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects![row])
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        if reminderStreakPicker.selectedRow(inComponent: 0) > 0 {

            let row = reminderStreakPicker.selectedRow(inComponent: 0) - 1
            print("daily reminder sent")
            guard let streak = StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?[row] else {return}
            scheduleReminderNotification(streak: streak)
            StreakController.shared.toggle(reminder: true, ofStreak: streak)
            reminderTimeDefaultTextField.text = displayHourAndMinute(forDate: timeStreakPicker.date)
            StreakController.shared.set(reminderTime: timeStreakPicker.date, ofStreak: streak)

        } else {
            print("daily reminder turn off")
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ["DailyReminder"])
        }
    }
    func changeDefaultTextAlert(forRow row: Int) {
        guard let streak = StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?[row], let streakName = streak.name else {return}
        
        let textAlert = UIAlertController(title: nil, message: NSLocalizedString("Edit the default text for the reminder", comment: "Call to action in text Alert to change notification body"), preferredStyle: .alert)
        
        textAlert.addTextField { (defaultText) in
            if let text = streak.reminderText {
                defaultText.text = text
            } else {
                defaultText.text = String.localizedStringWithFormat(
                    NSLocalizedString("Did you continue your streak of %@?", comment: "Default Text in notification"), streakName)
            }
        }
        
        let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: "Save Textchange"), style: .default) { (_) in
            guard let newText = textAlert.textFields?.first?.text else {return}
            StreakController.shared.set(reminderText: newText, ofStreak: streak)
            self.scheduleReminderNotification(streak: streak)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Textchange"), style: .cancel, handler: nil)
        
        textAlert.addAction(saveAction)
        textAlert.addAction(cancelAction)
        
        present(textAlert, animated: true)
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        sortButton.isEnabled = !editing
        tap.isEnabled = !editing
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
        var streakLabel = NSLocalizedString("SELECT A STREAK", comment: "Placeholdertext for the pickerview")
        if StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?.count == 0 {
            streakLabel = NSLocalizedString("no current Streak available", comment: "Default message if no streak is availabe")
        }
        if row != 0 {
            streakLabel = StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?[row - 1].name ?? "empty"
        }
        return streakLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        resetPickerSelections()
        if row > 0 {
            //"a streak was selected"
            switch pickerView.tag {
            case 1111:
                badgeSelectionTextField.text = StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?[row - 1].name ?? "Streak not found"
            case 2222:
                guard let streak = StreakController.shared.unfinishedStreakfetchResultsController.fetchedObjects?[row - 1] else {return}
                reminderSelectionTextField.text = streak.name ?? "Streak not found"
                reminderTextDefaultButton.isEnabled = true
                reminderTimeDefaultTextField.isEnabled = true
                reminderTimeDefaultTextField.text = displayHourAndMinute(forDate: streak.reminderTime ?? Calendar.current.date(bySetting: .hour, value: 16, of: Date())!)
                timeStreakPicker.date = streak.reminderTime ?? Calendar.current.date(bySetting: .hour, value: 16, of: Date())!

            default:
                break
            }

        } else {
            //"select a row was selected"
            
            switch pickerView.tag {
            case 1111:
                badgeSelectionTextField.text = NSLocalizedString("Select a Streak", comment: "Placeholdertext for the badgeSelectionTextFiled")
            case 2222:
                reminderSelectionTextField.text = NSLocalizedString("Select a Streak", comment: "Placeholdertext for the reminderSelectionTextField")
                reminderTextDefaultButton.isEnabled = false
                reminderTimeDefaultTextField.isEnabled = false
                reminderTimeDefaultTextField.text = ""

            default:
                break
            }
        }
    }
}
//MARK: - TextField Delegate
extension SaveScreenViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        tap.isEnabled = true
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        tap.isEnabled = false
        userDissmissedPickerView()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool  {
        return false
    }
}
