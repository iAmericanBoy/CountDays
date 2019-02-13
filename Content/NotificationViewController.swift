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
    @IBOutlet weak var streakNameLabel: UILabel!
    @IBOutlet weak var streakNumberLabel: UILabel!
    @IBOutlet weak var streakTextLabel: UILabel!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        self.streakTextLabel?.text = notification.request.content.body
        self.streakNameLabel?.text = notification.request.content.title
        self.streakNumberLabel?.text = notification.request.content.userInfo["count"] as! String
    }

}
