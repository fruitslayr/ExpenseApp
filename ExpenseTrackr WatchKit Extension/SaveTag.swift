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
    
    var listOfTags: [Tag]!
    
    @IBOutlet weak var interfaceTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        listOfTags = context as [Tag]
        
        interfaceTable.setNumberOfRows(listOfTags.count, withRowType: WatchStoryboard.tag)
        
        for i in 0..<listOfTags.count {
            configureRowAtIndex(i)
        }
    }
    
    func configureRowAtIndex(index: Int) {
        
        let item = interfaceTable.rowControllerAtIndex(index) as TagItemRowController
        
        item.setText(listOfTags[index].text)
        item.setColor(listOfTags[index].color)

    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        popController()
    }
    
}
