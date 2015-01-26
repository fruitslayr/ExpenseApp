//
//  TagItemRowController.swift
//  ExpenseTrackr
//
//  Created by Francis Young on 26/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import WatchKit

class TagItemRowController: NSObject {
   
    @IBOutlet weak var textLabel: WKInterfaceLabel!
    
    @IBOutlet weak var tagColor: WKInterfaceGroup!
    
    func setText(string: String) {
        textLabel.setText(string)
    }
    
    func setColor(color: UIColor) {
        tagColor.setBackgroundColor(color)
    }
    
    
}
