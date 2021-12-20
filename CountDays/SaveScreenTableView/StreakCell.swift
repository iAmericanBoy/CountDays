//
//  StreakCell.swift
//  CountDays
//
//  Created by Dominic Lanzillotta on 9/17/18.
//  Copyright © 2018 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class StreakCell: UITableViewCell {
    
    //MARK: - Properties
    ///Variable that controlls if the progress circle is lushgreen of red. If set to false the progress will be red and if set to true the prgress will be set to green
    var unFinishedStreak = false
    
    ///This ratio sets the progress of the circle. The standard value is 1 so the colored circle will be full. It has to be a value between 0 and 1
    var progressRatio:Float = 1.0
    
    //MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }
    
    //MARK: - LifeCycle
    override func prepareForReuse() {
        super.prepareForReuse()
        setNeedsDisplay()
        progressRatio = 1.0
    }
    
    //MARK: - UIElements
    ///The label that displays the name of the streak
    var streakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()
    
    ///The label that shows the number of days of the streak, inside the progress circle
    var streakNumberLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius =  20
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - SetupView
    private func setupUI() {
        backgroundColor = .systemBackground
        self.contentView.addSubview(streakLabel)
        streakLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15).isActive = true
        streakLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 15).isActive = true
        streakLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -50).isActive = true
        streakLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -15).isActive = true
        self.contentView.addSubview(streakNumberLabel)

        streakNumberLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        streakNumberLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -(contentView.bounds.height * 0.34)).isActive = true
    }
    
    //MARK: - Custum UI
    override func draw(_ rect: CGRect) {
        var unfinishedColor = UIColor.lushGreenColor

        if unFinishedStreak {
            unfinishedColor = UIColor.systemRed
        }
        
        let labelRect = CGRect(x: contentView.bounds.maxX - contentView.bounds.height * 0.85, y: contentView.bounds.maxY - contentView.bounds.height * 0.86, width: contentView.bounds.height * 0.76, height: contentView.bounds.height * 0.76)
        
        let endAngelVal = (360 * progressRatio) - 90

        let greyPath = UIBezierPath(ovalIn: labelRect)
        UIColor.systemGray.withAlphaComponent(0.8).setStroke()
        greyPath.lineWidth = 3
        greyPath.lineJoinStyle = .bevel
        greyPath.stroke()
        let ovalRect = labelRect
        let ovalPath = UIBezierPath()
        ovalPath.addArc(withCenter: CGPoint.zero, radius: ovalRect.width / 2, startAngle: -90 * CGFloat.pi/180, endAngle: CGFloat(endAngelVal) * CGFloat.pi/180, clockwise: true)
        var ovalTransform = CGAffineTransform(translationX: ovalRect.midX, y: ovalRect.midY)
        ovalTransform = ovalTransform.scaledBy(x: 1, y: ovalRect.height / ovalRect.width)
        ovalPath.apply(ovalTransform)
        
        unfinishedColor.setStroke()
        ovalPath.lineWidth = 3
        ovalPath.lineJoinStyle = .bevel
        ovalPath.stroke()
    }
}
