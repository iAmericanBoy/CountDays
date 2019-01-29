//
//  WidgetStreakViewCell.swift
//  DaysInARow Widget
//
//  Created by Dominic Lanzillotta on 10/25/18.
//  Copyright © 2018 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class WidgetStreakViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        addSubview(streakName)
        streakName.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2).isActive = true
        streakName.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        streakName.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        
        addSubview(roundLable)
        roundLable.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -18).isActive = true
        roundLable.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -6).isActive = true
        roundLable.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        roundLable.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        roundLable.layer.cornerRadius = contentView.bounds.width * 0.25
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var progress = 1.0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let smallSquare = CGRect(x: contentView.bounds.minX  , y: contentView.bounds.minY, width: contentView.bounds.width * 0.95 , height: contentView.bounds.width * 0.95)

        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: smallSquare.minX , y: smallSquare.maxY))
        trianglePath.addLine(to: CGPoint(x: smallSquare.maxX, y: smallSquare.maxY))
        trianglePath.addLine(to: CGPoint(x: smallSquare.maxX, y: smallSquare.minY))
        trianglePath.addLine(to: CGPoint(x: smallSquare.minX , y: smallSquare.maxY))
        UIColor.lightGray.withAlphaComponent(0.0).setFill()
        trianglePath.lineCapStyle = .round
        trianglePath.close()
        trianglePath.fill()
        
        let fullValX = ((smallSquare.width / 100) * CGFloat(1 * 100)) - 6
        let fullValY = (smallSquare.width - fullValX)
        
        let backgroundProgressBar = UIBezierPath()
        backgroundProgressBar.move(to: CGPoint(x: smallSquare.minX + 3, y: smallSquare.maxY - 3))
        backgroundProgressBar.addLine(to: CGPoint(x: smallSquare.minX + 3 + min(fullValX,smallSquare.width - 6), y: smallSquare.minY - 3 + max(fullValY,0 + 6)))
        UIColor.lightGray.withAlphaComponent(0.6).setStroke()
        backgroundProgressBar.lineWidth = 5
        backgroundProgressBar.lineCapStyle = .round
        backgroundProgressBar.stroke()
        
        
        let valX = ((smallSquare.width / 100) * CGFloat(progress * 100)) - 6
        let valY = (smallSquare.width - valX)
        
        let progressBezier = UIBezierPath()
        progressBezier.move(to: CGPoint(x: smallSquare.minX + 3, y: smallSquare.maxY - 3))
        progressBezier.addLine(to: CGPoint(x: smallSquare.minX + 3 + min(valX,smallSquare.width - 6), y: smallSquare.minY - 3 + max(valY,0 + 6)))
        UIColor.lushGreenColor.setStroke()
        progressBezier.lineWidth = 4
        progressBezier.lineCapStyle = .round
        progressBezier.stroke()
    }
    
    
    let streakName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    let roundLable: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 25)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        label.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.lushGreenColor.withAlphaComponent(0.9).cgColor
        label.clipsToBounds = true
        return label
    }()
}
