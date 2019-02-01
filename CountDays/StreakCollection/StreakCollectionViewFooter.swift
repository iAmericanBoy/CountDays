//
//  File.swift
//  CountDays
//
//  Created by Dominic Lanzillotta on 9/18/18.
//  Copyright © 2018 Dominic Lanzillotta. All rights reserved.
//

import UIKit

protocol CollectionViewFooterDelegate : class {
    func segueToSaveScreen()
}

class StreakCollectionViewFooter: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    weak var delegate: CollectionViewFooterDelegate?

    func goToSaveScreen() {
        self.delegate?.segueToSaveScreen()
    }
}
