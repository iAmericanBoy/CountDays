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
    @IBOutlet weak var dayLabel: UILabel!
    
    //MARK: - Properties
    let todayAtMidnight = Calendar.current.startOfDay(for: Date())
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func didReceive(_ notification: UNNotification) {
        self.notificationBodyLabel.text = notification.request.content.body
        
        let uuidAsString = notification.request.content.userInfo[UserInfoDictionary.uuid] as! String
        StreakController.shared.findStreakWith(uuid: UUID(uuidString: uuidAsString)) { (streak) in
            guard let streak = streak else {return}
            DispatchQueue.main.async {
                
                self.streakNameLabel.text = streak.name
                let startDay = streak.start
                
                let count = Calendar.current.dateComponents([ .day], from: startDay ?? self.todayAtMidnight, to: self.todayAtMidnight).day! + 1
                self.streakCountLabel.text =  "\(count)"
                
                self.dayLabel.text = count == 1 ? "Day" : "Days"
                
                if streak.goal != 0 {
                    self.progressBarView.progress = Float(count) / Float(streak.goal)
                } else {
                    self.progressBarView.progress = 1
                }
            }
        }
    }
    
    //MARK: - Private Functions
    func setupUI() {
        streakCountLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 150, weight: UIFont.Weight.thin)
        dayLabel.layer.borderWidth = 3
        dayLabel.layer.cornerRadius = dayLabel.frame.size.width / 2.0
        dayLabel.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        dayLabel.layer.cornerRadius = 0.2 * view.bounds.size.width * 0.51
        dayLabel.layer.masksToBounds = true
    }
    
}
