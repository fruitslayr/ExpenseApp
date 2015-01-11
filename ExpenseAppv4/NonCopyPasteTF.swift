//
//  NonCopyPasteTF.swift
//  ExpenseAppv4
//
//  Created by Francis Young on 29/12/2014.
//  Copyright (c) 2014 Francis Young. All rights reserved.
//

import UIKit

class NonCopyPasteTF: UITextField {
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return false
    }
    
    override func closestPositionToPoint(point: CGPoint) -> UITextPosition! {
        let beginning = self.beginningOfDocument
        let end = self.positionFromPosition(beginning, offset: countElements(self.text))
        return end
    }
    
    override func addGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.isKindOfClass(UILongPressGestureRecognizer) {
            gestureRecognizer.enabled = false
        }
        
        return super.addGestureRecognizer(gestureRecognizer)
    }

}
