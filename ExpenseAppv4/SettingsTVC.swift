//
//  SettingsTVC.swift
//  ExpenseAppTestv4
//
//  Created by Francis Young on 27/12/2014.
//  Copyright (c) 2014 Francis Young. All rights reserved.
//

import UIKit

class SettingsTVC: UITableViewController, UITextFieldDelegate {

    @IBAction func close(segue:UIStoryboardSegue) {}
    var coreDataStack: CoreDataStack!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var emailUs: UIButton!
    
    //change color of buttons when selected
    @IBOutlet weak var weeklyLimit: UITextField!
    var weeklyLimitLeftView = UITextField(frame: CGRectMake(0, 0, 10, 20))
    
    @IBOutlet weak var curencySymbol: UISegmentedControl!
    @IBOutlet weak var defaultView:UISegmentedControl!
    @IBAction func clickedCurencySymbol() {
        curencySymbol.tintColor = appColor.selectedTintColor
        defaults.setInteger(self.curencySymbol.selectedSegmentIndex, forKey: "currencySymbol")
        
        var tempString = self.weeklyLimit.text
        tempString.removeAtIndex(weeklyLimit.text.startIndex)
        weeklyLimit.text = getCurrencySymbol() + tempString
    }
    
    @IBAction func clickedDefaultView() {
        defaultView.tintColor = appColor.selectedTintColor
        defaults.setInteger(self.defaultView.selectedSegmentIndex, forKey: "defaultView")
    }
    
    //opening settings
    var defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Buttons reacting
        let buttonList:[UIButton] = [button1, button3, button5, emailUs]
        
        for index in 0...3 {
            buttonList[index].layer.cornerRadius = 5.0
            buttonList[index].layer.borderColor = appColor.headerTintColor.CGColor
            buttonList[index].layer.borderWidth = 1.0
            buttonList[index].setTitleColor(appColor.headerTintColor, forState: .Normal)
        }
        
        //loading default settings
        if let currencySymbolIsNotNil = defaults.objectForKey("currencySymbol") as? Int {
            self.curencySymbol.selectedSegmentIndex = defaults.objectForKey("currencySymbol") as Int
        }
        
        if let weeklyLimitIsNotNil = defaults.objectForKey("weeklyLimit") as? String {
            let tempString = defaults.objectForKey("weeklyLimit") as String
            self.weeklyLimit.text = getCurrencySymbol() + tempString
        }
        
        if let defaultViewIsNotNil = defaults.objectForKey("defaultView") as? Int {
            self.defaultView.selectedSegmentIndex = defaults.objectForKey("defaultView") as Int
        }
        
        self.weeklyLimit.delegate = self
        
        //custom tool bar set up
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.bounds.size.height, 320, 44))
        toolBar.translucent = true
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action:"weeklyLimitDone")
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action:"weeklyLimitCancel")
        cancelButton.tintColor = UIColor.redColor()
        let flexiSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action:"flexispace")
        
        let toolbarButtonItems = [cancelButton, flexiSpace, doneButton]
        toolBar.setItems(toolbarButtonItems, animated: false)
        
        self.weeklyLimit.inputAccessoryView = toolBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    //TableViewDelegate
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 && indexPath.section == 0 {
            weeklyLimit.becomeFirstResponder()
        } else if indexPath.row == 1 && indexPath.section == 0 {
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryView = MSCellAccessory(type: MSCellAccessoryType.FLAT_DISCLOSURE_INDICATOR, color: appColor.selectedTintColor)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //weeklyLimit delegate implementation
    func textFieldDidBeginEditing(textField: UITextField) {
        //setting to completely clear the textField
        //weeklyLimit.text = getCurrencySymbol()
        weeklyLimit.textColor = appColor.selectedTintColor
    }
    
    //prevent deletion of first character + 2 decimal points + starting with 0
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let charactersToCheck = Array(textField.text + string)
        var foundDecimalPoint = false
        
        if (countElements(textField.text) + countElements(string)) > 1 {
            if (countElements(textField.text) + countElements(string)) > 2 {
                
                var placesAfterDecimalPoint = 0
                for c in charactersToCheck {
                    
                    if foundDecimalPoint {
                        
                        placesAfterDecimalPoint += 1
                        
                        if placesAfterDecimalPoint == 3 {
                            errorShakeView(textField)
                            return false
                        }
                    }
                    
                    if c == "." {
                        if foundDecimalPoint {
                            errorShakeView(textField)
                            return false
                        }
                        foundDecimalPoint = true
                    }
                }
                
                if (countElements(textField.text) + countElements(string)) > 10 {
                    errorShakeView(textField)
                    return false
                }

                return true
            } else {
                if string == "0" {
                    errorShakeView(textField)
                    return false
                }
                return true
            }
        } else {
            errorShakeView(textField)
            return false
        }
    }
    
    //Changing weeklyLimit
    func weeklyLimitDone() {
        weeklyLimit.resignFirstResponder()
        
        //Saving changes
        var tempString = self.weeklyLimit.text
        tempString.removeAtIndex(weeklyLimit.text.startIndex)
        defaults.setObject(tempString, forKey: "weeklyLimit")
    }

    func weeklyLimitCancel() {
        var output = ""
        
        output += getCurrencySymbol()
        if let weeklyLimitIsNotNil = defaults.objectForKey("weeklyLimit") as? String {
            let limit = defaults.objectForKey("weeklyLimit") as String
            output += String(limit)
        }
        
        weeklyLimit.text = output
        weeklyLimit.resignFirstResponder()
    }
    
    //maintaining dollar symbol @ front of textfield
    
    //return currencySymbol as String
    func getCurrencySymbol() -> String {
        var output = ""
        
        if let currencySymbolIsNotNil = defaults.objectForKey("currencySymbol") as? Int {
            let symbol = defaults.objectForKey("currencySymbol") as Int
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toManageTags" {
            let destinationController = segue.destinationViewController as ManageTagsTVC
            destinationController.coreDataStack = self.coreDataStack
        }
    }

}
