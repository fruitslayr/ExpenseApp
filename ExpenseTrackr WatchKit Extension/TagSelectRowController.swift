//
//  TagItemRowController.swift
//  ExpenseTrackr
//
//  Created by Francis Young on 26/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import WatchKit

class TagSelectRowController: NSObject {
    
    @IBOutlet weak var tagColor: WKInterfaceGroup!
    
    func setColor(color: UIColor) {
        tagColor.setBackgroundColor(color)
    }
    
    
}
