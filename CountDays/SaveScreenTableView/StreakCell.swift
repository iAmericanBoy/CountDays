//
//  StreakCell.swift
//  CountDays
//
//  Created by Dominic Lanzillotta on 9/17/18.
//  Copyright © 2018 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class StreakCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setNeedsDisplay()
        progressRatio = 1.0
    }
    
    ///The label that displays the name of the streak
    var streakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    ///Variable that controlls if the progress circle is lushgreen of red. If set to false the progress will be red and if set to true the prgress will be set to green
    var unFinishedStreak = false
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }
    ///The label that shows the number of days of the streak, inside the progress circle
    var streakNumberLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius =  20
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    ///This ratio sets the progress of the circle. The standard value is 1 so the colored circle will be full. It has to be a value between 0 and 1
    var progressRatio:Float = 1.0
    
    override func draw(_ rect: CGRect) {
        var unfinishedColor = UIColor.lushGreenColor

        if unFinishedStreak {
            unfinishedColor = UIColor.red
        }
        
        let labelRect = CGRect(x: contentView.bounds.maxX - 46, y: contentView.bounds.maxY - 47, width: 42, height: 42)
        
        let endAngelVal = (360 * progressRatio) - 90

        let greyPath = UIBezierPath(ovalIn: labelRect)
        UIColor.lightGray.withAlphaComponent(0.8).setStroke()
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
    
    
    
    private func setupViews() {
        backgroundColor = .white
        self.contentView.addSubview(streakLabel)
        streakLabel.adjustsFontSizeToFitWidth = true
        streakLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        streakLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 5).isActive = true
        streakLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -50).isActive = true
        streakLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.contentView.addSubview(streakNumberLabel)
        streakNumberLabel.adjustsFontSizeToFitWidth = true
        streakNumberLabel.widthAnchor.constraint(equalToConstant: 36).isActive = true
        streakNumberLabel.heightAnchor.constraint(equalToConstant: 36).isActive = true
        streakNumberLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        streakNumberLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -7).isActive = true
    }
}
