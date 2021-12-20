//
//  StreakCollectionViewCell.swift
//  CountDays
//
//  Created by Dominic Lanzillotta on 9/14/18.
//  Copyright © 2018 Dominic Lanzillotta. All rights reserved.
//

import UIKit

protocol CollectionViewCellDelegate: class {
    func showChangeNameAlert(_ cell: StreakCollectionViewCell)
    func getDateAlert(_ cell: StreakCollectionViewCell)
    func getGoalAlert(_ cell: StreakCollectionViewCell)
    func restartStreak(_ cell: StreakCollectionViewCell)
    func saveStreak(_ cell: StreakCollectionViewCell)
    func segueToSaveScreen()
    func newEmptyStreakButtonPressed(_ cell: StreakCollectionViewCell)
}

class StreakCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: CollectionViewCellDelegate?
    

    let streakNumberButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 50, weight: UIFont.Weight.medium)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.baselineAdjustment = .alignCenters
        button.contentVerticalAlignment = .top
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let smallSquareView = UIView()

    let roundDaysbutton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Day", comment: "The title on the daybutton"), for: .normal)
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
    
    let streakNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Start new Streak", comment: "The title on the streak Name Button"), for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.largeTitle)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.clipsToBounds = false
        button.titleLabel?.baselineAdjustment = .alignCenters
        return button
    }()
    
    let restartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("RESTART", comment: "The title on the restart StreakButton"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.clipsToBounds = false
        button.backgroundColor = UIColor(red:(232/255),green: (36/255),blue: (35/255),alpha: 0.7)
        button.titleLabel?.baselineAdjustment = .alignCenters
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.red.cgColor
        return button
    }()
    
    let finishButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("FINISH", comment: "The title on the finish Streak button"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.clipsToBounds = false
        button.backgroundColor = .lushGreenColor
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
    
    let newEmptyStreak: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("＋", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 35)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.baselineAdjustment = .alignCenters
        button.setTitleColor(.lushGreenColor, for: .normal)
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 22
        button.layer.borderColor = UIColor.lushGreenColor.cgColor

        return button
    }()
    
    var progress:Float = 1.0
    
    override func draw(_ rect: CGRect) {
        let smallSquare = CGRect(x: contentView.bounds.midX - 2, y: contentView.bounds.midY, width: contentView.bounds.width * 0.5 , height: contentView.bounds.width * 0.5)
        
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: smallSquare.minX , y: smallSquare.maxY))
        trianglePath.addLine(to: CGPoint(x: smallSquare.maxX, y: smallSquare.maxY))
        trianglePath.addLine(to: CGPoint(x: smallSquare.maxX, y: smallSquare.minY))
        trianglePath.addLine(to: CGPoint(x: smallSquare.minX , y: smallSquare.maxY))
        UIColor.lightGray.withAlphaComponent(0.5).setFill()
        trianglePath.lineCapStyle = .round
        trianglePath.close()
        trianglePath.fill()
        
        let valX = ((smallSquare.width / 100) * CGFloat(progress * 100)) - 6
        let valY = (smallSquare.width - valX)
        
        let progressBezier = UIBezierPath()
        progressBezier.move(to: CGPoint(x: smallSquare.minX + 3, y: smallSquare.maxY - 3))
        progressBezier.addLine(to: CGPoint(x: smallSquare.minX + 3 + min(valX,smallSquare.width - 6), y: smallSquare.minY - 3 + max(valY,0 + 6)))
        UIColor.lushGreenColor.setStroke()
        progressBezier.lineWidth = 7
        progressBezier.lineCapStyle = .round
        progressBezier.stroke()
    }
    

    func setupView(){
        let margins = contentView.safeAreaLayoutGuide

        contentView.addSubview(smallSquareView)
        smallSquareView.translatesAutoresizingMaskIntoConstraints = false
        smallSquareView.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.5).isActive = true
        smallSquareView.heightAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.5).isActive = true
        smallSquareView.topAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        smallSquareView.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
        
        contentView.addSubview(openSaveScreenButton)
        openSaveScreenButton.topAnchor.constraint(equalTo: margins.topAnchor,constant: 5).isActive = true
        openSaveScreenButton.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -20).isActive = true
        openSaveScreenButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        openSaveScreenButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        
        contentView.addSubview(newEmptyStreak)
        newEmptyStreak.topAnchor.constraint(equalTo: margins.topAnchor,constant: 5).isActive = true
        newEmptyStreak.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 20).isActive = true
        newEmptyStreak.heightAnchor.constraint(equalToConstant: 45).isActive = true
        newEmptyStreak.widthAnchor.constraint(equalToConstant: 45).isActive = true
        
        contentView.addSubview(streakNumberButton)
        streakNumberButton.widthAnchor.constraint(equalTo: margins.widthAnchor).isActive = true
        streakNumberButton.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        streakNumberButton.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        streakNumberButton.heightAnchor.constraint(equalTo: margins.widthAnchor).isActive = true
        
        let nameStackView = UIStackView(arrangedSubviews: [streakNameButton])
        contentView.addSubview(nameStackView)
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        nameStackView.topAnchor.constraint(equalTo: newEmptyStreak.bottomAnchor).isActive = true
        nameStackView.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -10).isActive = true
        nameStackView.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 10).isActive = true
        nameStackView.bottomAnchor.constraint(equalTo: streakNumberButton.topAnchor).isActive = true
        nameStackView.axis = .horizontal
        nameStackView.distribution = .fillEqually
        nameStackView.spacing = 15
        nameStackView.alignment = .center

        contentView.addSubview(roundDaysbutton)
        roundDaysbutton.bottomAnchor.constraint(equalTo: smallSquareView.bottomAnchor, constant: -5).isActive = true
        roundDaysbutton.rightAnchor.constraint(equalTo: smallSquareView.rightAnchor, constant: -5).isActive = true
        roundDaysbutton.heightAnchor.constraint(equalTo: smallSquareView.heightAnchor, multiplier: 0.53).isActive = true
        roundDaysbutton.widthAnchor.constraint(equalTo: smallSquareView.widthAnchor, multiplier: 0.53).isActive = true
        roundDaysbutton.layer.cornerRadius = 0.25 * contentView.bounds.size.width * 0.53
        
        let bottomButtonArea = UIStackView(arrangedSubviews: [restartButton,finishButton])
        contentView.addSubview(bottomButtonArea)
        bottomButtonArea.translatesAutoresizingMaskIntoConstraints = false
        bottomButtonArea.topAnchor.constraint(equalTo: smallSquareView.bottomAnchor, constant: 5).isActive = true
        bottomButtonArea.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -5).isActive = true
        bottomButtonArea.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 5).isActive = true
        bottomButtonArea.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -40).isActive = true
        bottomButtonArea.axis = .horizontal
        bottomButtonArea.distribution = .fillEqually
        bottomButtonArea.spacing = 10
        bottomButtonArea.alignment = .center
        
        //targets
        roundDaysbutton.addTarget(self, action: #selector(changeGoalAlert), for: .touchUpInside)
        openSaveScreenButton.addTarget(self, action: #selector(openSaveScreenButtonPressed), for: .touchUpInside)
        newEmptyStreak.addTarget(self, action: #selector(newEmptyStreakButtonPressed), for: .touchUpInside)
        streakNumberButton.addTarget(self, action: #selector(changeStartDayAlert), for: .touchUpInside)
        streakNameButton.addTarget(self, action: #selector(changeStreakNameAlert), for: .touchUpInside)
        restartButton.addTarget(self, action: #selector(restartButtonPressed), for: .touchUpInside)
        finishButton.addTarget(self, action: #selector(finishButtonPressed), for: .touchUpInside)
    }
    
    
    func updateUI(){
        
        if streakNumberButton.title(for: .normal)!.count > 2 {
            streakNumberButton.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: contentView.bounds.height * 0.25, weight: UIFont.Weight.thin)
        } else {
            streakNumberButton.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: contentView.bounds.height * 0.31, weight: UIFont.Weight.thin)
        }
        
        setNeedsDisplay()
        if streakNameButton.title(for: .normal) == NSLocalizedString("Start new Streak", comment: "The title on the sttreak name button"){
            finishButton.isEnabled = false
            restartButton.isEnabled = false
            streakNumberButton.isEnabled = false
            roundDaysbutton.isEnabled = false
            streakNameButton.setTitleColor(.lightGray, for: .normal)
        } else {
            finishButton.isEnabled = true
            restartButton.isEnabled = true
            streakNumberButton.isEnabled = true
            roundDaysbutton.isEnabled = true
            streakNameButton.setTitleColor(.black, for: .normal)
        }
    }
    
    //Actions
    @objc func changeGoalAlert(sender: UIButton) {
        print("changeGoalAlert")
        self.delegate?.getGoalAlert(self)
        updateUI()
    }
    @objc func newEmptyStreakButtonPressed(sender: UIButton) {
        print("newEmptyStreakButtonPressed")
        self.delegate?.newEmptyStreakButtonPressed(self)
        updateUI()
    }
    @objc func openSaveScreenButtonPressed(sender: UIButton) {
        print("openSaveScreenButtonPressed")
        self.delegate?.segueToSaveScreen()
        updateUI()
    }
    @objc func changeStartDayAlert(sender: UIButton) {
        print("changeStartDayAlert")
        self.delegate?.getDateAlert(self)
        updateUI()
    }
    @objc func changeStreakNameAlert(sender: UIButton) {
        print("changeStreakNameAlert")
        self.delegate?.showChangeNameAlert(self)
        updateUI()
    }
    @objc func restartButtonPressed(sender: UIButton) {
        print("restartButtonPressed")
        self.delegate?.restartStreak(self)
        streakNameButton.setTitle(NSLocalizedString("Start new Streak", comment: "The title on the streak Name Button"), for: .normal)
        updateUI()
    }
    @objc func finishButtonPressed(sender: UIButton) {
        print("finishButtonPressed")
        streakNumberButton.setTitle("0", for: .normal)
        self.delegate?.saveStreak(self)
        updateUI()
    }
}
