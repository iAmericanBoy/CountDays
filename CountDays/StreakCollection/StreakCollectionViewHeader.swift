//
//  StreakCollectionViewCell.swift
//  CountDays
//
//  Created by Dominic Lanzillotta on 9/14/18.
//  Copyright © 2018 Dominic Lanzillotta. All rights reserved.
//

import UIKit

protocol CollectionViewHeaderDelegate: class {
    func showChangeNameAlert(_ cell: StreakCollectionViewHeader)
    func segueToSaveScreen()
}

class StreakCollectionViewHeader: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        setupView()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: CollectionViewHeaderDelegate?
    
    let streakNumberButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("0", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 450)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.baselineAdjustment = .alignCenters
        button.setTitleColor(UIColor.black.withAlphaComponent(0.8), for: .normal)
        return button
    }()
    
    let smallSquareView = UIView()
    
    let roundDaysbutton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Day", comment: "The title on the daybutton"), for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.clipsToBounds = false
        button.titleLabel?.baselineAdjustment = .alignCenters
        button.setTitleColor(UIColor.black.withAlphaComponent(0.8), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        return button
    }()
    
    let streakNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Start new Streak", comment: "The title on the streak Name Button"), for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.clipsToBounds = false
        button.titleLabel?.baselineAdjustment = .alignCenters
        return button
    }()
    
    let restartButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("RESTART", comment: "The title on the restart StreakButton"), for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.clipsToBounds = false
        button.backgroundColor = UIColor(red:(232/255),green: (36/255),blue: (35/255),alpha: 0.6)
        button.titleLabel?.baselineAdjustment = .alignCenters
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.red.withAlphaComponent(0.7).cgColor
        return button
    }()
    
    let finishButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("FINISH", comment: "The title on the finish Streak button"), for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.clipsToBounds = false
        button.backgroundColor = UIColor.lushGreenColor.withAlphaComponent(0.7)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        button.titleLabel?.baselineAdjustment = .alignCenters
        button.layer.cornerRadius = 10
        return button
    }()
    
    let openSaveScreenButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.backgroundColor = .lushGreenColor
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.setBackgroundImage(#imageLiteral(resourceName: "saveImage"), for: .normal)
        return button
    }()
 
    func setupView(){
        let margins = contentView.safeAreaLayoutGuide
        
        contentView.addSubview(smallSquareView)
        smallSquareView.translatesAutoresizingMaskIntoConstraints = false
        smallSquareView.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.5).isActive = true
        smallSquareView.heightAnchor.constraint(equalTo: margins.heightAnchor, multiplier: 0.25).isActive = true
        smallSquareView.topAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        smallSquareView.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
        
        contentView.addSubview(streakNumberButton)
        streakNumberButton.widthAnchor.constraint(equalTo: margins.widthAnchor).isActive = true
        streakNumberButton.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        streakNumberButton.heightAnchor.constraint(equalTo: margins.widthAnchor).isActive = true
        
        contentView.addSubview(roundDaysbutton)
        roundDaysbutton.topAnchor.constraint(equalTo: smallSquareView.topAnchor, constant: 50).isActive = true
        roundDaysbutton.rightAnchor.constraint(equalTo: smallSquareView.rightAnchor, constant: -25).isActive = true
        roundDaysbutton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        roundDaysbutton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        let topArea = UIStackView(arrangedSubviews: [streakNameButton])
        contentView.addSubview(topArea)
        topArea.translatesAutoresizingMaskIntoConstraints = false
        topArea.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        topArea.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -20).isActive = true
        topArea.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 20).isActive = true
        topArea.bottomAnchor.constraint(equalTo: streakNumberButton.topAnchor).isActive = true
        topArea.axis = .horizontal
        topArea.distribution = .fillEqually
        topArea.spacing = 15
        topArea.alignment = .center
        
        let bottomButtonArea = UIStackView(arrangedSubviews: [restartButton,finishButton])
        contentView.addSubview(bottomButtonArea)
        bottomButtonArea.translatesAutoresizingMaskIntoConstraints = false
        bottomButtonArea.topAnchor.constraint(equalTo: streakNumberButton.bottomAnchor, constant: 5).isActive = true
        bottomButtonArea.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -20).isActive = true
        bottomButtonArea.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 20).isActive = true
        bottomButtonArea.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -40).isActive = true
        bottomButtonArea.axis = .horizontal
        bottomButtonArea.distribution = .fillEqually
        bottomButtonArea.spacing = 15
        bottomButtonArea.alignment = .center
        
        contentView.addSubview(openSaveScreenButton)
        openSaveScreenButton.topAnchor.constraint(equalTo: margins.topAnchor,constant: 5).isActive = true
        openSaveScreenButton.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -20).isActive = true
        openSaveScreenButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        openSaveScreenButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        
        //targets
        roundDaysbutton.addTarget(self, action: #selector(changeGoalAlert), for: .touchUpInside)
        openSaveScreenButton.addTarget(self, action: #selector(openSaveScreenButtonPressed), for: .touchUpInside)
        streakNumberButton.addTarget(self, action: #selector(changeStartDayAlert), for: .touchUpInside)
        streakNameButton.addTarget(self, action: #selector(changeStreakNameAlert), for: .touchUpInside)
        restartButton.addTarget(self, action: #selector(restartButtonPressed), for: .touchUpInside)
        finishButton.addTarget(self, action: #selector(finishButtonPressed), for: .touchUpInside)
    }
    
    func updateUI(){
        if streakNameButton.title(for: .normal) == NSLocalizedString("Start new Streak", comment: "The title on the sttreak name button"){
            finishButton.isEnabled = false
            restartButton.isEnabled = false
            streakNumberButton.isEnabled = false
            roundDaysbutton.isEnabled = false
            streakNameButton.isEnabled = true
        } else {
            finishButton.isEnabled = true
            restartButton.isEnabled = true
            streakNumberButton.isEnabled = true
            roundDaysbutton.isEnabled = true
            streakNameButton.setTitleColor(.black, for: .normal)
            streakNameButton.isEnabled = false
        }
        if streakNumberButton.titleLabel?.text == "1" {
            roundDaysbutton.setTitle(NSLocalizedString("Day", comment: "The title on the daybutton with one count"), for: .normal)
        } else {
            roundDaysbutton.setTitle(NSLocalizedString("Days", comment: "The title on the daybutton with multiple counts"), for: .normal)
        }
    }
    
    
    //Actions
    @objc func changeGoalAlert(sender: UIButton) {
        print("changeGoalAlert")
        updateUI()
    }

    @objc func openSaveScreenButtonPressed(sender: UIButton) {
        print("openSaveScreenButtonPressed")
        self.delegate?.segueToSaveScreen()
        updateUI()
    }
    @objc func changeStartDayAlert(sender: UIButton) {
        print("changeStartDayAlert")
        updateUI()
    }
    @objc func changeStreakNameAlert(sender: UIButton) {
        print("changeStreakNameAlert")
        self.delegate?.showChangeNameAlert(self)
        updateUI()
    }
    @objc func restartButtonPressed(sender: UIButton) {
        print("restartButtonPressed")
        updateUI()
    }
    @objc func finishButtonPressed(sender: UIButton) {
        print("finishButtonPressed")
        updateUI()
    }
}
    

