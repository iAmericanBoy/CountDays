//
//  ViewWithProgressBar.swift
//  Content
//
//  Created by Dominic Lanzillotta on 2/13/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class ViewWithProgressBar: UIView {
    
    var progress:Float = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }


    override func draw(_ rect: CGRect) {
        let smallSquare = CGRect(x: self.bounds.midX - 2, y: self.bounds.midY, width: self.bounds.width * 0.5 , height: self.bounds.width * 0.5)
        
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

}
