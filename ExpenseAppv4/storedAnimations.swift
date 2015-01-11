//
//  storedAnimations.swift
//  ExpenseAppv4
//
//  Created by Francis Young on 30/12/2014.
//  Copyright (c) 2014 Francis Young. All rights reserved.
//

import Foundation
import UIKit

func errorShakeView(view: UIView){
    //Shake animation
    var shake:CABasicAnimation = CABasicAnimation(keyPath: "position")
    shake.duration = 0.05
    shake.repeatCount = 2
    shake.autoreverses = true

    var from_point:CGPoint = CGPointMake(view.center.x - 5, view.center.y)
    var from_value:NSValue = NSValue(CGPoint: from_point)
    
    var to_point:CGPoint = CGPointMake(view.center.x + 5, view.center.y)
    var to_value:NSValue = NSValue(CGPoint: to_point)
    
    shake.fromValue = from_value
    shake.toValue = to_value
    view.layer.addAnimation(shake, forKey: "position")
}
