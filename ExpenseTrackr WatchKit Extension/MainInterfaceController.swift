//
//  MainInterfaceController.swift
//  ExpenseTrackr
//
//  Created by Francis Young on 26/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import Foundation
import WatchKit
import CoreData

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
   
    //Shared user defaults
    var defaults = NSUserDefaults(suiteName: "group.edu.self.ExpenseTrackr.Documents")
    //Shared settings
    var currencySymbol = ""
    
    //Test variable
    var anInt = 0
    
    @IBOutlet weak var addButton: WKInterfaceButton!
    @IBOutlet weak var interfaceTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.        
        interfaceTable.setRowTypes([WatchStoryboard.RowTypes.tag, WatchStoryboard.RowTypes.amount])
        currencySymbol = getCurrencySymbol()
        
        let amountRow = interfaceTable.rowControllerAtIndex(1) as AmountSelectRowController
        amountRow.setSymbol(currencySymbol)
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
    
    //return currencySymbol as String
    func getCurrencySymbol() -> String {
        var output = ""
        if let symbol = defaults?.objectForKey("currencySymbol") as? Int {
            switch symbol {
            case 0:
                output += "$"
            case 1:
                output += "£"
            case 2:
                output += "€"
            default:
                output = ""
            }
        }
        return output
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        if rowIndex == 1 {
            return currencySymbol
        } else if rowIndex == 0 {
            return 1
        } else {
            return nil
        }
    }

}
