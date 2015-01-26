//
//  SaveAmount.swift
//  ExpenseTrackr
//
//  Created by Francis Young on 26/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import Foundation
import WatchKit

class SaveAmount: WKInterfaceController {
    
    @IBOutlet weak var amountTextLabel: WKInterfaceLabel!
    var amountText = ""
    @IBOutlet weak var dollarSymbolLabel: WKInterfaceLabel!
    
//    @IBOutlet weak var button1: WKInterfaceButton!
//    @IBOutlet weak var button2: WKInterfaceButton!
//    @IBOutlet weak var button3: WKInterfaceButton!
//    
//    @IBOutlet weak var button4: WKInterfaceButton!
//    @IBOutlet weak var button5: WKInterfaceButton!
//    @IBOutlet weak var button6: WKInterfaceButton!
//    
//    @IBOutlet weak var button7: WKInterfaceButton!
//    @IBOutlet weak var button8: WKInterfaceButton!
//    @IBOutlet weak var button9: WKInterfaceButton!
//    
//    @IBOutlet weak var buttonDecimal: WKInterfaceButton!
//    @IBOutlet weak var button0: WKInterfaceButton!
//    @IBOutlet weak var buttonClear: WKInterfaceButton!
    
    @IBAction func button1() {
        updateTextlabel("1")
    }
    @IBAction func button2() {
        updateTextlabel("2")
    }
    @IBAction func button3() {
        updateTextlabel("3")
    }
    
    @IBAction func button4() {
        updateTextlabel("4")
    }
    @IBAction func button5() {
        updateTextlabel("5")
    }
    @IBAction func button6() {
        updateTextlabel("6")
    }
    
    @IBAction func button7() {
        updateTextlabel("7")
    }
    @IBAction func button8() {
        updateTextlabel("8")
    }
    @IBAction func button9() {
        updateTextlabel("9")
    }
    
    @IBAction func buttonDecimal() {
        updateTextlabel(".")
    }
    @IBAction func button0() {
        updateTextlabel("0")
    }
    @IBAction func buttonClear() {
        updateTextlabel("C")
    }
    
    
    override func awakeWithContext(context: AnyObject?) {
        amountTextLabel.setText("")
        dollarSymbolLabel.setText("%")
    }
    
    func updateTextlabel(str:String) {
        if str == "C" {
            amountText = ""
        } else {
            amountText += str
        }
        
        amountTextLabel.setText(amountText)
    }
    
    
    
    
}