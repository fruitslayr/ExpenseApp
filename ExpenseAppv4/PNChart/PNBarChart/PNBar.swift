//
//  PNBar.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/6/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit
import QuartzCore

class PNBar:UIView {
        
    var grade: [CGFloat] = [] {
        didSet {
            
            ///////Working on creating multistack graph
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
                
            /*
            // animates the drawing up effect
            var pathAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = 1.0
            pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pathAnimation.fromValue = 0.0
            pathAnimation.toValue = 1.0
            chartLine.addAnimation(pathAnimation, forKey:"strokeEndAnimation")
            */
            chartLine[i].strokeEnd = 1.0
            
            UIGraphicsEndImageContext()
                
            }
        }
    }
    var chartLine: [CAShapeLayer] = []
    var barColor: [UIColor] = []
    
    var barRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = barRadius
        }
    }
    
    //Not used
    /*
    func rollBack() {
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({() -> Void in
                self.chartLine.strokeColor = UIColor.clearColor().CGColor
            }), completion: ({(Bool) -> Void in
                
            }) )
    }*/
    
    init(frame: CGRect, colors: [UIColor])
    {
        super.init(frame: frame)
        barColor = colors
                
        for i in 0..<barColor.count {
            chartLine.append(CAShapeLayer())
            chartLine[i].lineCap      = kCALineCapButt
            chartLine[i].fillColor    = UIColor.whiteColor().CGColor
            chartLine[i].lineWidth    = frame.size.width
            chartLine[i].strokeEnd    = 0.0
            clipsToBounds      = true
            backgroundColor = PNLightGreyColor
            layer.addSublayer(chartLine[i])
            
            
            barRadius = 2.0 //does nothing as overriden in PNBarChart.swift
        }

    }
    
    /*
    func animate() {
        //animate bar drawing up effect
        
        let animatedLayer = CAShapeLayer()
        animatedLayer.frame = frame
        animatedLayer.lineCap      = kCALineCapButt
        animatedLayer.lineWidth    = self.frame.size.width
        animatedLayer.strokeEnd    = 0.0
        
        layer.addSublayer(animatedLayer)
        
        UIGraphicsBeginImageContext(self.frame.size)
        var progressline:UIBezierPath = UIBezierPath()
        progressline.moveToPoint(CGPointMake(self.frame.size.width / 2.0, self.frame.size.height))
        progressline.addLineToPoint(CGPointMake(self.frame.size.width / 2.0, 0))
        progressline.lineWidth = 1.0
        progressline.lineCapStyle = kCGLineCapSquare
        animatedLayer.path = progressline.CGPath
        animatedLayer.strokeColor = UIColor.blackColor().CGColor
        
        /*
        var pathAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 1.0
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue = 1.0
        animatedLayer.addAnimation(pathAnimation, forKey:"strokeEndAnimation")
        */
        
        animatedLayer.strokeEnd = 1.0
        UIGraphicsEndImageContext()
        
    }*/

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    //sets the background color of the cell
    override func drawRect(rect: CGRect)
    {
        //Draw BG
        var context: CGContextRef = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, self.backgroundColor?.CGColor)
        CGContextFillRect(context, rect)
    }
    */

}
