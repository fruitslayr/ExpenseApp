//
//  NewExpenseTVC.swift
//  ExpenseAppTestv4
//
//  Created by Francis Young on 27/12/2014.
//  Copyright (c) 2014 Francis Young. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class NewExpenseTVC: UITableViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, SetLocationDelegate {
    
    @IBOutlet weak var nameOfExpense: UITextField!
    @IBOutlet weak var tagSelected:UITextField!
        var tempTagSelected = ""
        var tagToSave: Tag?
    @IBOutlet weak var amountSelected:UITextField!
        var tempAmountSelected = ""
    @IBOutlet weak var dateAndTime:UITextField!
        var tempDateAndTime = NSDate()
        var selectedDateAndTime: NSDate = NSDate()
    
    
    //for datePicker
    let datePicker = UIDatePicker()
    func datePickerChanged(sender: UIDatePicker) {
        selectedDateAndTime = sender.date
        dateAndTime.text = printDateAndTime(selectedDateAndTime)
    }

    
    //opening settings + coredatastack
    var defaults = NSUserDefaults(suiteName: "group.edu.self.ExpenseTrackr.Documents")
    var coreDataStack: CoreDataStack!
    var listOfTags: [Tag]!
    
    //manager for getting location
    var manager: OneShotLocationManager?
    var setLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserLocation()
        
        //get Tag list form coreDataStack
        let fetchRequest = NSFetchRequest(entityName: "Tag")
        var error: NSError? = nil
        
        let tagSort = NSSortDescriptor(key: "position", ascending: true)
        fetchRequest.sortDescriptors = [tagSort]
        
        listOfTags = coreDataStack.context.executeFetchRequest(fetchRequest, error: &error) as [Tag]

        //setting delegates of textfields to self
        self.nameOfExpense.delegate = self
        self.amountSelected.delegate = self
        self.tagSelected.delegate = self
        self.dateAndTime.delegate = self
        
        //set symbol for dolar sign
        amountSelected.text = getCurrencySymbol()
        
        //tagSelect pickerview setup
        let picker = UIPickerView(frame: CGRectMake(0, self.view.bounds.size.height, 320, 100))
        picker.dataSource = self
        picker.delegate = self
        self.tagSelected.inputView = picker
        
        //custom tagSelect toolbar set up
        let tagToolbar = UIToolbar(frame: CGRectMake(0, self.view.bounds.size.height, 320, 44))
        tagToolbar.translucent = true
        
        let tagDoneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action:"doneTagSelected")
        let tagCancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action:"cancelTagSelected")
        tagCancelButton.tintColor = UIColor.redColor()
        let tagFlexiSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action:"flexispace")

        let tagToolbarButtonItems = [tagCancelButton, tagFlexiSpace, tagDoneButton]
        tagToolbar.setItems(tagToolbarButtonItems, animated: false)
        
        self.tagSelected.inputAccessoryView = tagToolbar
        
        //custom label for tagSelected
        tagSelected.text = listOfTags[0].text
        tagToSave = listOfTags[0]
        
        // dateAndTime pickerview setup
        datePicker.frame = CGRectMake(0, self.view.bounds.size.height, 320, 100)
        datePicker.datePickerMode = UIDatePickerMode.DateAndTime
        //datePicker.minuteInterval = 10
        datePicker.date = NSDate()
        datePicker.maximumDate = NSDate()
        
        self.dateAndTime.inputView = datePicker
        
        datePicker.addTarget(self, action: "datePickerChanged:", forControlEvents: .ValueChanged)

        
        ///get current time for dateAndTime
        dateAndTime.text = printDateAndTime(datePicker.date)
        
        //custom dateAndTime toolbar set up
        let dateAndTimeToolbar = UIToolbar(frame: CGRectMake(0, self.view.bounds.size.height, 320, 44))
        dateAndTimeToolbar.translucent = true
        
        let dateAndTimeDoneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action:"doneDateAndTime")
        let dateAndTimeCancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action:"cancelDateAndTime")
        dateAndTimeCancelButton.tintColor = UIColor.redColor()
        let dateAndTimeFlexiSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action:"flexispace")
        
        let dateAndTimeToolbarButtonItems = [dateAndTimeCancelButton, dateAndTimeFlexiSpace, dateAndTimeDoneButton]
        dateAndTimeToolbar.setItems(dateAndTimeToolbarButtonItems, animated: false)
        
        self.dateAndTime.inputAccessoryView = dateAndTimeToolbar
        
        //custom amountSelected toolbar set up
        
        let amountToolbar = UIToolbar(frame: CGRectMake(0, self.view.bounds.size.height, 320, 44))
        amountToolbar.translucent = true
        
        let amountDoneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action:"doneAmountSelected")
        let amountCancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action:"cancelAmountSelected")
        amountCancelButton.tintColor = UIColor.redColor()
        let amountFlexiSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action:"flexispace")
        
        let amountToolbarButtonItems = [amountCancelButton, amountFlexiSpace, amountDoneButton]
        amountToolbar.setItems(amountToolbarButtonItems, animated: false)
        
        self.amountSelected.inputAccessoryView = amountToolbar

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function for tagSelectedToolBar
    func doneTagSelected() {tagSelected.resignFirstResponder() /*MUST IMPLEMENT LOGIC TO SAVE CHANGES*/}
    func cancelTagSelected() {
        tagSelected.resignFirstResponder()
        tagSelected.text = tempTagSelected
    }
    
    //Function for dateAndTimeToolBar
    func doneDateAndTime() {
        dateAndTime.resignFirstResponder()
        /*MUST IMPLEMENT LOGIC TO SAVE CHANGES*/
        selectedDateAndTime = datePicker.date
        dateAndTime.text = printDateAndTime(datePicker.date)
    }
    func cancelDateAndTime() {
        dateAndTime.resignFirstResponder()
        dateAndTime.text = printDateAndTime(tempDateAndTime)
        selectedDateAndTime = tempDateAndTime
    }
    
    
    //Dismiss keyboard when touch 'Done' button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.nameOfExpense {
            textField.resignFirstResponder()
        }
        return true
    }
    
    //Deselect tableViewCell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                amountSelected.becomeFirstResponder()
            } else if indexPath.row == 1 {
                tagSelected.becomeFirstResponder()
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                nameOfExpense.becomeFirstResponder()
            } else if indexPath.row == 1 {
                dateAndTime.becomeFirstResponder()
            } else if indexPath.row == 2 {
                if setLocation != nil {
                    let cell = self.tableView.cellForRowAtIndexPath(indexPath)
                    cell?.accessoryView = MSCellAccessory(type: MSCellAccessoryType.FLAT_DISCLOSURE_INDICATOR, color: appColor.selectedTintColor)
                }
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        
        //ISSUE WITH THIS CODE
        
        headerView
        
        let label = UILabel(frame: CGRectMake(30, 30, 260, 10))
        label.textColor = appColor.orangeColor
        label.font = UIFont.systemFontOfSize(14)
        if section == 0 {
            label.text = "ESSENTIALS"
        } else if section == 1 {
            label.text = "EXTRAS"
        }
        
        headerView.addSubview(label)
        
        
        
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    //PickerDataSource + PickerDelegate
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.listOfTags.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.listOfTags[row].text
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    //Issues with size of UILabel -> Want it to resize to accomodate entire length of text
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var myIcon: UIImageView = UIImageView(image: imageWithColor(listOfTags[row].color as UIColor))
        myIcon.frame = CGRectMake(75, 5, 30, 30)
        myIcon.layer.cornerRadius = myIcon.frame.size.width/2
        myIcon.clipsToBounds = true
        
        var myText: UILabel = UILabel(frame: CGRectMake(115, 0, 150, 40))
        myText.font = UIFont.systemFontOfSize(20)
        myText.text = listOfTags[row].text
        myText.sizeToFit()

        let heightCorrection = (40 - myText.frame.height)/2
        let widthCorrection = (320 - (40 + myText.frame.width) )/2
        myIcon.frame = CGRectMake(widthCorrection, 5, 30, 30)
        myText.frame = CGRectMake(widthCorrection + 40, heightCorrection, myText.frame.width, myText.frame.height)
        
        
        var tempView: UIView = UIView(frame: CGRectMake(0, 0, 320, 40))
        tempView.addSubview(myIcon)
        tempView.addSubview(myText)
        
        //For testing purposes only
        //tempView.layer.borderColor = UIColor.redColor().CGColor
        //tempView.layer.borderWidth = 1
        
        return tempView
    }

    //creating UIImage with designated color
    func imageWithColor(color: UIColor) -> UIImage {
        var rect = CGRectMake(0, 0, 30, 30)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.tagToSave = self.listOfTags[row]
        self.tagSelected.text = self.listOfTags[row].text
    }
    
    //textField delegate implementation
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.textColor = appColor.selectedTintColor
        
        if textField == amountSelected {
            var tempString = self.amountSelected.text
            tempString.removeAtIndex(amountSelected.text.startIndex)
            tempAmountSelected = tempString
    
            amountSelected.text = getCurrencySymbol()
        } else if textField == tagSelected {
            tempTagSelected = tagSelected.text
        } else if textField == dateAndTime {
            tempDateAndTime = selectedDateAndTime
        }
    }

    
    
    //controll response of textFields to character changes --> FOR amountSelected!! (prevent deletion of first character + 2 decimal points + starting with 0)
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        if textField == amountSelected {
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
        } else if textField == nameOfExpense {
            if (countElements(textField.text) + countElements(string)) > 30 {
                errorShakeView(textField) //CHARACTER LIMIT OF 30
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    //Changing weeklyLimit
    func doneAmountSelected() {
        amountSelected.resignFirstResponder()
        //Saving changes
    }
    
    func cancelAmountSelected() {
        amountSelected.text = getCurrencySymbol() + tempAmountSelected
        amountSelected.resignFirstResponder()
    }
    
    //maintaining dollar symbol @ front of textfield
    
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
 
    //printing date and time
    func printDateAndTime(date:NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        var theDateFormat = NSDateFormatterStyle.MediumStyle
        let theTimeFormat = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateStyle = theDateFormat
        dateFormatter.timeStyle = theTimeFormat
        
        return dateFormatter.stringFromDate(date)
    }
    
    //delegate for SetLocationVC
    func updateLocation(controller: SetLocationVC, location: CLLocationCoordinate2D) {
        self.setLocation = location
    }
    
    //prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "setLocation" {
            let destinationController = segue.destinationViewController as SetLocationVC
            destinationController.userLocation = self.setLocation
            destinationController.delegate = self
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "setLocation" && setLocation == nil {
            let optionMenu = UIAlertController(title: "Error", message: "Unable to set location due to location preferences turned off. Go to settings to turn on location preferences.", preferredStyle: .Alert)

            // Add Settings action to the menu
            let settingAction = UIAlertAction(title: "Settings", style: .Cancel, handler: {_ -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
                return
            })
            optionMenu.addAction(settingAction)
            
            // Add Cancel action to the menu
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            optionMenu.addAction(cancelAction)
            
            self.presentViewController(optionMenu, animated: true, completion: nil)
            
            return false
        } else {
            return true
        }
    }
    
    func getUserLocation() {
        //get users current location
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            if let loc = location {
                self.setLocation = loc.coordinate
            } else if let err = error {
                println(err.localizedDescription)
                self.setLocation = nil
            }
            self.manager = nil
        }
    }
    
    @IBAction func saveExpense() {
        
        if countElements(amountSelected.text) < 2 {
        //if the amountSelected has been filled: --> Create an option menu as an action sheet
            let optionMenu = UIAlertController(title: "Oops!", message: "You need to input an amount before you can save this expense.", preferredStyle: .Alert)

            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            optionMenu.addAction(okAction)
            
            self.presentViewController(optionMenu, animated: true, completion: nil )

        } else {
            //save new expense
            let newExpense = NSEntityDescription.insertNewObjectForEntityForName("Expense", inManagedObjectContext: self.coreDataStack.context) as Expense
            
            //essential things that must be saved
            newExpense.amount = NSNumber(double: (amountSelected.text.substringFromIndex(amountSelected.text.startIndex.successor()) as NSString).doubleValue) //Seems risky liable to problems in the future
            newExpense.tag = tagToSave
            

            //extra things that can be saved
            if nameOfExpense.text != "" {
                newExpense.name = nameOfExpense.text
            } else {
                newExpense.name = nil
            }
            
            if setLocation != nil {
                let newCoordinate = NSEntityDescription.insertNewObjectForEntityForName("Coordinate", inManagedObjectContext: self.coreDataStack.context) as Coordinate
                newCoordinate.latitude = setLocation!.latitude
                newCoordinate.longitude = setLocation!.longitude
                newExpense.coordinate = newCoordinate
            } else {
                newExpense.coordinate = nil
            }
            
            newExpense.dateAndTime = selectedDateAndTime

            self.coreDataStack.saveContext()
        
            //performs unwind segue
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }
    }
    
    
    
    
    
    
    

}
