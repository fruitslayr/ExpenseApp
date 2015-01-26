//
//  MainInterfaceController.swift
//  ExpenseTrackr
//
//  Created by Francis Young on 26/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import Foundation
import WatchKit

class MainInterfaceController: WKInterfaceController {

    struct WatchStoryboard {
        //static let interfaceControllerName = "MainInterfaceController"
        
        struct RowTypes {
            static let tag = "TagSelectionRowType"
            static let amount = "AmountSelectionRowType"
        }
        
        struct Segues {
            //static let listSelection = "WatchListsInterfaceControllerListSelectionSegue"
        }
    }
    
    @IBOutlet weak var addButton: WKInterfaceButton!
    @IBOutlet weak var interfaceTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.        
        interfaceTable.setRowTypes([WatchStoryboard.RowTypes.tag, WatchStoryboard.RowTypes.amount])
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        println("Runs")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
