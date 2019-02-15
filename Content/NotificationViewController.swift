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
    var streak: Streak? {
        didSet {
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func didReceive(_ notification: UNNotification) {
        self.notificationBodyLabel.text = notification.request.content.body

        StreakController.shared.findStreakWith(uuid: notification.request.content.userInfo[UserInfoDictionary.uuid] as? UUID) { (streak) in
            self.streak = streak
        }
    }
    
    //MARK: - Private Functions
    func updateViews(){
        guard let streak = streak else {return}
        self.streakNameLabel.text = streak.name
        let startDay = streak.start
        
        let count = Calendar.current.dateComponents([ .day], from: startDay ?? todayAtMidnight, to: todayAtMidnight).day! + 1
        self.streakCountLabel.text =  "\(count)"
        
        let goal = streak.goal
        if  goal != 0 {
            progressBarView.progress = Float(count) / Float(goal)
        } else {
            progressBarView.progress = 1
        }
    }
}
