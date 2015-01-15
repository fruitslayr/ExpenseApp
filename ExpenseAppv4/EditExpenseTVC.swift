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

class EditExpenseTVC: UITableViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, SetLocationDelegate {
    
    var expenseItem: Expense!
    
    @IBOutlet weak var nameOfExpense: UITextField!
    @IBOutlet weak var tagSelected:UITextField!
        var tempTagSelected = ""
        var tagToSave: Tag?
    @IBOutlet weak var amountSelected:UITextField!
        var tempAmountSelected = ""
    @IBOutlet weak var dateAndTime:UITextField!
    var tempDateAndTime: NSDate!
        var selectedDateAndTime: NSDate!
    
    var setLocation: CLLocationCoordinate2D?

    //for datePicker
    let datePicker = UIDatePicker()
    func datePickerChanged(sender: UIDatePicker) {
        selectedDateAndTime = sender.date
        dateAndTime.text = printDateAndTime(selectedDateAndTime)
    }
    
    
    //opening settings + coredatastack
    var defaults = NSUserDefaults.standardUserDefaults()
    var coreDataStack: CoreDataStack!
    var listOfTags: [Tag]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let coordinate = expenseItem.coordinate {
            setLocation = CLLocationCoordinate2D(latitude: coordinate.latitude.doubleValue, longitude: coordinate.longitude.doubleValue)
        } else {
            setLocation = CLLocationCoordinate2D(latitude: -33.8683, longitude: 151.2086)
        }
        
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
        amountSelected.text = "\(getCurrencySymbol())\(expenseItem.amount)"
        
        //name of expense
        nameOfExpense.text = expenseItem.name
        
        //tagSelect pickerview setup
        let picker = UIPickerView(frame: CGRectMake(0, self.view.bounds.size.height, 320, 100))
        picker.dataSource = self
        picker.delegate = self
        self.tagSelected.inputView = picker
        picker.selectRow(self.expenseItem.tag.position.integerValue, inComponent: 0, animated: false)
        
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
        tagSelected.text = expenseItem.tag.text
        tagToSave = expenseItem.tag
        
        // dateAndTime pickerview setup
        datePicker.frame = CGRectMake(0, self.view.bounds.size.height, 320, 100)
        datePicker.datePickerMode = UIDatePickerMode.DateAndTime
        //datePicker.minuteInterval = 10
        tempDateAndTime = expenseItem.dateAndTime
        datePicker.setDate(expenseItem.dateAndTime, animated: false)
        datePicker.maximumDate = NSDate()
        
        self.dateAndTime.inputView = datePicker
        
        datePicker.addTarget(self, action: "datePickerChanged:", forControlEvents: .ValueChanged)
        
        
        ///get current time for dateAndTime
        dateAndTime.text = printDateAndTime(datePicker.date)
        selectedDateAndTime = tempDateAndTime
        
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
    
    override func viewWillDisappear(animated: Bool) {
        if countElements(amountSelected.text) < 2 {
            //if the amountSelected has been filled: --> Create an option menu as an action sheet
            let optionMenu = UIAlertController(title: "Oops!", message: "You need to input an amount before you can save this expense.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            optionMenu.addAction(okAction)
            
            self.presentViewController(optionMenu, animated: true, completion: nil )
            
        } else {
            //save editted expense
            //essential things that must be saved
            expenseItem.amount = NSNumber(double: (amountSelected.text.substringFromIndex(amountSelected.text.startIndex.successor()) as NSString).doubleValue) //Seems risky liable to problems in the future
            expenseItem.tag = tagToSave
            
            
            //extra things that can be saved
            if nameOfExpense.text != "" {
                expenseItem.name = nameOfExpense.text
            } else {
                expenseItem.name = nil
            }
            
            if setLocation != nil {
                let newCoordinate = NSEntityDescription.insertNewObjectForEntityForName("Coordinate", inManagedObjectContext: self.coreDataStack.context) as Coordinate
                newCoordinate.latitude = setLocation!.latitude
                newCoordinate.longitude = setLocation!.longitude
                expenseItem.coordinate = newCoordinate
            } else {
                expenseItem.coordinate = nil
            }
            
            expenseItem.dateAndTime = selectedDateAndTime
            
            self.coreDataStack.saveContext()
            
        }

    }
    
    
    
    
    
    
    
    
}
