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
            static let tagSelection = "showTagPicker"
            static let amountSelection = "showAmountPicker"
        }
    }
    
    //Test variable
    var anInt = 0
    
    @IBOutlet weak var addButton: WKInterfaceButton!
    @IBOutlet weak var interfaceTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.        
        interfaceTable.setRowTypes([WatchStoryboard.RowTypes.tag, WatchStoryboard.RowTypes.amount])
        
        println(context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func ButtonAction() {
        addButton.setColor(UIColor.orangeColor())
        addButton.setEnabled(true)
    }

}
