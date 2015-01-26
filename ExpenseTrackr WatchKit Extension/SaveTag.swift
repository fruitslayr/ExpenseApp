//
//  SaveTag.swift
//  ExpenseTrackr
//
//  Created by Francis Young on 26/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import Foundation
import WatchKit

class SaveTag: WKInterfaceController {
    
    struct WatchStoryboard {
        //static let interfaceControllerName = "SaveTag"
        
        static let tag = "TagItemRowController"
        
    }
    
    //Test data
    var colors: [UIColor] = [UIColor(red: 149/255, green: 192/255, blue: 232/255, alpha: 1), UIColor(red: 222/255, green: 192/255, blue: 232/255, alpha: 1)]
    var labels: [String] = ["Default Tag", "Example: Food & Drink"]
    
    @IBOutlet weak var interfaceTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        
        interfaceTable.setNumberOfRows(colors.count, withRowType: WatchStoryboard.tag)
        
        for i in 0..<colors.count {
            configureRowAtIndex(i)
        }
    }
    
    func configureRowAtIndex(index: Int) {
        
        let item = interfaceTable.rowControllerAtIndex(index) as TagItemRowController
        
        item.setText(labels[index])
        item.setColor(colors[index])

    }
    
}
