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
    let smallSquareView = UIView()
    
    @IBOutlet weak var progressBarView: ViewWithProgressBar!
    
    let streakNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Start new Streak"
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = false
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        return label
    }()
    
    let streakNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 100, weight: UIFont.Weight.light)
        label.text = "0"
        label.clipsToBounds = true

        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        return label
    }()
    let roundDaysbutton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Day", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.clipsToBounds = false
        button.titleLabel?.baselineAdjustment = .alignCenters
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 3
        button.layer.cornerRadius = button.frame.size.width / 2.0
        button.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        return button
    }()
    
    let streakBodyLabel: UILabel = {
        let label = UILabel()
        label.text = "BodyText here"
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = false
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        return label
    }()
    
    
    //MARK: - Properties
    var progress:Float = 1.0
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func didReceive(_ notification: UNNotification) {
//        self.streakTextLabel?.text = notification.request.content.body
        self.streakNameLabel.text = notification.request.content.title
        self.streakNumberLabel.text = notification.request.content.userInfo["count"] as? String
    }
    
    
    //MARK: - Add ProgressTriangle
    func updateProgressTriangle(){
        view.addSubview(smallSquareView)
        smallSquareView.translatesAutoresizingMaskIntoConstraints = false
        smallSquareView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        smallSquareView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        smallSquareView.topAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        smallSquareView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    //MARK: - Private Functions
    func updateUI() {
        let margins = view.safeAreaLayoutGuide

        updateProgressTriangle()
        
        progressBarView.progress = progress
        progressBarView.setNeedsDisplay()
        
        let notificationStack = UIStackView(arrangedSubviews: [streakNameLabel,streakNumberLabel,streakBodyLabel])
        notificationStack.alignment = .fill
        notificationStack.distribution = .fill
        notificationStack.spacing = 50
        notificationStack.axis = .vertical
        
        view.addSubview(notificationStack)
        notificationStack.sizeToFit()
        
//        view.addSubview(streakNameLabel)
//        streakNameLabel.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
//        streakNameLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
//        streakNameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
//        streakNameLabel.heightAnchor.constraint(equalTo: view.heightAnchor , multiplier: 0.20).isActive = true
//
//        view.addSubview(streakNumberLabel)
//        streakNumberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        streakNumberLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(roundDaysbutton)
        roundDaysbutton.bottomAnchor.constraint(equalTo: smallSquareView.bottomAnchor, constant: -5).isActive = true
        roundDaysbutton.rightAnchor.constraint(equalTo: smallSquareView.rightAnchor, constant: -5).isActive = true
        roundDaysbutton.heightAnchor.constraint(equalTo: smallSquareView.heightAnchor, multiplier: 0.53).isActive = true
        roundDaysbutton.widthAnchor.constraint(equalTo: smallSquareView.widthAnchor, multiplier: 0.53).isActive = true
        roundDaysbutton.layer.cornerRadius = 0.25 * view.bounds.size.width * 0.53
        
//        view.addSubview(streakBodyLabel)
//        streakBodyLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
//        streakBodyLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
//        streakBodyLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
//        streakBodyLabel.heightAnchor.constraint(equalTo: view.heightAnchor , multiplier: 0.20).isActive = true
        
    }


}
