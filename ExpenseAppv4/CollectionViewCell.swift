//
//  CollectionViewCell.swift
//  test3
//
//  Created by Francis Young on 12/02/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    var bar: UIView = UIView(frame: CGRect(x: 0, y: 8, width: 42, height: 314))
    var dateLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 330, width: 42, height: 16))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        dateLabel.font = UIFont.systemFontOfSize(11)
        dateLabel.textAlignment = .Center
        
        contentView.addSubview(bar)
        contentView.addSubview(dateLabel)
    }
    
    var _selected = false
    
    override var selected: Bool {
        get {
            return _selected
        }set(newState) {
            if newState == true {
                UIView.animateWithDuration(0.2, delay: 0.0,usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: nil, animations: {
                    self.bar.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    self.dateLabel.frame = CGRect(x: 0, y: 334.5, width: 42, height: 16)
                    self.dateLabel.font = UIFont.boldSystemFontOfSize(11)
                }, completion: nil)
            } else {
                UIView.animateWithDuration(0.2, delay: 0.0,usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: nil, animations: {
                    self.bar.transform = CGAffineTransformMakeScale(1, 1)
                    self.dateLabel.frame = CGRect(x: 0, y: 330, width: 42, height: 16)
                    self.dateLabel.font = UIFont.systemFontOfSize(11)
                }, completion: nil)
            }
            
            _selected = newState
        }
    }
    
    
}