//
//  TagItemRowController.swift
//  ExpenseTrackr
//
//  Created by Francis Young on 26/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import WatchKit

class AmountSelectRowController: NSObject {
    
    @IBOutlet weak var amountTextLabel: WKInterfaceLabel!
    
    @IBOutlet weak var currencySymbolLabel: WKInterfaceLabel!
    
    func setAmount(string: String) {
        amountTextLabel.setText(string)
    }
    
    func setSymbol(char: String) {
        currencySymbolLabel.setText(char)
    }
    
    
}
