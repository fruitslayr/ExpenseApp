//
//  CollectionViewCell.swift
//  test3
//
//  Created by Francis Young on 12/02/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    var bar = UIView(frame: CGRect(x: 0, y: 8, width: 42, height: 314))
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
    
    var overMaxValue: Bool = false {
        didSet(newState) {
            //create white diagonal line
            UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
            
            //Get current image context
            let context = UIGraphicsGetCurrentContext()
            
            // Perform the drawing
            CGContextSetLineWidth(context, 3)
            CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
            
            CGContextMoveToPoint(context, -5, self.frame.size.height/2 + 15 + 5)
            CGContextAddLineToPoint(context, self.frame.size.width + 5, self.frame.size.height/2 - 15 + 5)
            
            CGContextMoveToPoint(context, -5, self.frame.size.height/2 + 15 - 5)
            CGContextAddLineToPoint(context, self.frame.size.width + 5, self.frame.size.height/2 - 15 - 5)
            
            CGContextStrokePath(context)
            
            // Retrieve the drawn image
            let imageView = UIImageView(frame: CGRectMake(0, 0, bar.frame.size.width, bar.frame.size.height))
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            contentView.addSubview(imageView)
        }
    }
    
    var overLimitValue: Bool = false {
        didSet(newState) {
            if newState == true {
                self.dateLabel.textColor = UIColor.redColor()
            } else {
                self.dateLabel.textColor = UIColor.blackColor()
            }
        }
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
    
    var grade: [CGFloat] = [] {
        didSet {
            var prevMoveToPoint: CGPoint = CGPointMake(frame.size.width / 2.0, frame.size.height)
            var height: CGFloat = 0
            
            for i in 0..<grade.count {
                UIGraphicsBeginImageContext(frame.size)
                
                height += self.grade[i]
                var progressline:UIBezierPath = UIBezierPath()
                progressline.moveToPoint(prevMoveToPoint)
                prevMoveToPoint = CGPointMake(frame.size.width / 2.0, (1 - height) * frame.size.height)
                progressline.addLineToPoint(prevMoveToPoint)
                progressline.lineWidth = 1.0
                progressline.lineCapStyle = kCGLineCapSquare
                chartLine[i].path = progressline.CGPath
                chartLine[i].strokeColor = barColor[i].CGColor
                chartLine[i].strokeEnd = 1.0
                
                UIGraphicsEndImageContext()
            }
            
        }
    }
    
    var chartLine: [CAShapeLayer] = []
    
    var barColor: [UIColor] = [] {
        didSet(newColors) {
            for i in 0..<newColors.count {
                chartLine.append(CAShapeLayer())
                chartLine[i].lineCap = kCALineCapButt
                chartLine[i].fillColor = UIColor.whiteColor().CGColor
                chartLine[i].lineWidth = bar.frame.size.width
                chartLine[i].strokeEnd = 0.0
                bar.clipsToBounds = true
                bar.backgroundColor = UIColor(red: 246.0 / 255.0 , green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
                bar.layer.addSublayer(chartLine[i])
            }
        }
    }
    
}