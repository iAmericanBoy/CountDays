//
//  NotificationViewController.swift
//  Content
//
//  Created by Dominic Lanzillotta on 2/12/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    //MARK: - Outlets
    @IBOutlet weak var progressBarView: ViewWithProgressBar!
    @IBOutlet weak var streakNameLabel: UILabel!
    @IBOutlet weak var streakCountLabel: UILabel!
    @IBOutlet weak var notificationBodyLabel: UILabel!
    
    //MARK: - Properties
    let todayAtMidnight = Calendar.current.startOfDay(for: Date())

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func didReceive(_ notification: UNNotification) {
        
        self.streakNameLabel.text = notification.request.content.userInfo[UserInfoDictionary.name] as? String
        let startDay = notification.request.content.userInfo[UserInfoDictionary.start] as? Date

        let count = Calendar.current.dateComponents([ .day], from: startDay ?? todayAtMidnight, to: todayAtMidnight).day! + 1
        self.streakCountLabel.text =  "\(count)"
        self.notificationBodyLabel.text = notification.request.content.body
//
        if let goal = notification.request.content.userInfo[UserInfoDictionary.goal] as? Int, goal != 0 {
            progressBarView.progress = Float(count) / Float(goal)
        } else {
            progressBarView.progress = 1
        }
        
    }
}
