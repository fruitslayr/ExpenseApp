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
    
    //Shared user defaults
    var defaults = NSUserDefaults(suiteName: "group.edu.self.ExpenseTrackr.Documents")
    
    @IBOutlet weak var amountTextLabel: WKInterfaceLabel!
    var amountText = ""
    @IBOutlet weak var dollarSymbolLabel: WKInterfaceLabel!
    
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
        
        //defaults?.objectForKey("amountTextLabel") as? Int {
        
        dollarSymbolLabel.setText((context as String))
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