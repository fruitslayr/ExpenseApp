//
//  SettingsTVC.swift
//  ExpenseAppTestv4
//
//  Created by Francis Young on 27/12/2014.
//  Copyright (c) 2014 Francis Young. All rights reserved.
//

import UIKit
import MessageUI
import CoreData

class SettingsTVC: UITableViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {

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
    
    //Function to send support email
    @IBAction func sendSupportEmailButton() {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.navigationBar.tintColor = UIColor.whiteColor()
        
        mailComposerVC.setToRecipients(["fruitslayr@icloud.com"])
        mailComposerVC.setSubject("Support/Feedback")
        
        let deviceInfo = UIDevice()
        var emailBody = "\n\n\n\n\n"
        emailBody += "Device Version: \(deviceInfo.systemName) \(deviceInfo.systemVersion)\n"
        emailBody += "Device Model: \(platformString())\n"
        
        mailComposerVC.setMessageBody(emailBody, isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposerVC, animated: true, completion: nil)
        } else {
            
            let errorAlert = UIAlertView(title: "Could not send an email", message: "Unable to send an email.  Please check device email settings and try again.", delegate: self, cancelButtonTitle: "Ok")
            errorAlert.show()
        }

    }
    
    //Function to export expense items via email
    @IBAction func exportExpensesEmailButton() {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.navigationBar.tintColor = UIColor.whiteColor()
        
        mailComposerVC.setSubject("Export Expenses")
        
        var emailBody = "\n\n\n\n\n*****Expense items*****\n"
        for expenseItem in getExpenses() {
            emailBody += "Date: \(printDateAndTime(expenseItem.dateAndTime))\n"
            
            if (expenseItem.name != nil) {
                emailBody += "Name: \(expenseItem.name!)\n"
            } else {
                emailBody += "Name: \n"
            }
            
            emailBody += "Amount: \(getCurrencySymbol())\(expenseItem.amount)\n"
            emailBody += "Tag: \(expenseItem.tag.text)\n\n"
        }
        
        mailComposerVC.setMessageBody(emailBody, isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposerVC, animated: true, completion: nil)
        } else {
            
            let errorAlert = UIAlertView(title: "Could not send an email", message: "Unable to send an email.  Please check device email settings and try again.", delegate: self, cancelButtonTitle: "Ok")
            errorAlert.show()
        }
        
    }

    
    
    //mail compose controller that responds when email composition is finished
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        
        if error != nil {
            println("Error: \(error)")
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
    
    func platform() -> String {
        var size : UInt = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](count: Int(size), repeatedValue: 0)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String.fromCString(machine)!
    }
    
    /********************************************/
    
    func platformString() -> String {
        
        var pf = platform();
        if (pf == "iPhone1,1")   { return  "iPhone 1G"}
        if ( pf   == "iPhone1,2"  )    {return  "iPhone 3G"}
        if (  pf   == "iPhone2,1"  )    { return  "iPhone 3GS"}
        if (  pf   == "iPhone3,1"  )    { return  "iPhone 4"}
        if (  pf   == "iPhone3,3"  )    { return  "Verizon iPhone 4"}
        if (  pf   == "iPhone4,1"  )    { return  "iPhone 4S"}
        if (  pf   == "iPhone5,1"  )    { return  "iPhone 5 (GSM)"}
        if (  pf   == "iPhone5,2"  )    { return  "iPhone 5 (GSM+CDMA)"}
        if (  pf   == "iPhone5,3"  )    { return  "iPhone 5c (GSM)"}
        if (  pf   == "iPhone5,4"  )    { return  "iPhone 5c (GSM+CDMA)"}
        if (  pf   == "iPhone6,1"  )    { return  "iPhone 5s (GSM)"}
        if (  pf   == "iPhone6,2"  )    { return  "iPhone 5s (GSM+CDMA)"}
        if (  pf   == "iPhone7,1"  )    { return  "iPhone 6 Plus"}
        if (  pf   == "iPhone7,2"  )    { return  "iPhone 6"}
        if (  pf   == "iPod1,1"  )      { return  "iPod Touch 1G"}
        if (  pf   == "iPod2,1"  )      { return  "iPod Touch 2G"}
        if (  pf   == "iPod3,1"  )      { return  "iPod Touch 3G"}
        if (  pf   == "iPod4,1"  )      { return  "iPod Touch 4G"}
        if (  pf   == "iPod5,1"  )      { return  "iPod Touch 5G"}
        if (  pf   == "iPad1,1"  )      { return  "iPad"}
        if (  pf   == "iPad2,1"  )      { return  "iPad 2 (WiFi)"}
        if (  pf   == "iPad2,2"  )      { return  "iPad 2 (GSM)"}
        if (  pf   == "iPad2,3"  )      { return  "iPad 2 (CDMA)"}
        if (  pf   == "iPad2,4"  )      { return  "iPad 2 (WiFi)"}
        if (  pf   == "iPad2,5"  )      { return  "iPad Mini (WiFi)"}
        if (  pf   == "iPad2,6"  )      { return  "iPad Mini (GSM)"}
        if (  pf   == "iPad2,7"  )      { return  "iPad Mini (GSM+CDMA)"}
        if (  pf   == "iPad3,1"  )      { return  "iPad 3 (WiFi)"}
        if (  pf   == "iPad3,2"  )      { return  "iPad 3 (GSM+CDMA)"}
        if (  pf   == "iPad3,3"  )      { return  "iPad 3 (GSM)"}
        if (  pf   == "iPad3,4"  )      { return  "iPad 4 (WiFi)"}
        if (  pf   == "iPad3,5"  )      { return  "iPad 4 (GSM)"}
        if (  pf   == "iPad3,6"  )      { return  "iPad 4 (GSM+CDMA)"}
        if (  pf   == "iPad4,1"  )      { return  "iPad Air (WiFi)"}
        if (  pf   == "iPad4,2"  )      { return  "iPad Air (Cellular)"}
        if (  pf   == "iPad4,4"  )      { return  "iPad mini 2G (WiFi)"}
        if (  pf   == "iPad4,5"  )      { return  "iPad mini 2G (Cellular)"}
        
        if (  pf   == "iPad4,7"  )      { return  "iPad mini 3 (WiFi)"}
        if (  pf   == "iPad4,8"  )      { return  "iPad mini 3 (Cellular)"}
        if (  pf   == "iPad4,9"  )      { return  "iPad mini 3 (China Model)"}
        
        if (  pf   == "iPad5,3"  )      { return  "iPad Air 2 (WiFi)"}
        if (  pf   == "iPad5,4"  )      { return  "iPad Air 2 (Cellular)"}
        
        if (  pf   == "i386"  )         { return  "Simulator"}
        if (  pf   == "x86_64"  )       { return  "Simulator"}
        return  pf
    }
    
    func getExpenses() -> [Expense] {
        //get Tag list form coreDataStack
        let fetchRequest = NSFetchRequest(entityName: "Expense")
        var error: NSError? = nil
        
        let expenseSort = NSSortDescriptor(key: "dateAndTime", ascending: false)
        fetchRequest.sortDescriptors = [expenseSort]
        
        var results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &error) as [Expense]
        
        return results
    }
    
    //printing date and time
    func printDateAndTime(date:NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        var theDateFormat = NSDateFormatterStyle.MediumStyle
        let theTimeFormat = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateStyle = theDateFormat
        dateFormatter.timeStyle = theTimeFormat
        
        return dateFormatter.stringFromDate(date)
    }

}
