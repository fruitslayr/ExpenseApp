//
//  DetailBarTVC.swift
//  ExpenseAppv4
//
//  Created by Francis Young on 11/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import UIKit

class DetailBarTVC: UITableViewController {

    var condensedListOfExpenses: [[Expense]]!
    var coreDataStack: CoreDataStack!
    var uncondensedListOfExpenses: [Expense] = [Expense]()
    
    var defaults = NSUserDefaults(suiteName: "group.edu.self.ExpenseTrackr.Documents")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.title = "Expense Items"
        
        for array in condensedListOfExpenses {
            for item in array {
                uncondensedListOfExpenses.append(item)
            }
        }
        
        //cell row height
        self.tableView.rowHeight = 60
        
        self.tableView.tableFooterView = UIView(frame:CGRectZero)
        
        //create date sort on expense array
        /*
        let expenseSort = NSSortDescriptor(key: "dateAndTime", ascending: false)
        uncondensedListOfExpenses.sort(<#isOrderedBefore: (T, T) -> Bool##(T, T) -> Bool#>)
        */
    }
    

    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return uncondensedListOfExpenses.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as customExpenseTableViewCell

        // Configure the cell...
        cell.expenseLabel.text = "\(getCurrencySymbol()) \(uncondensedListOfExpenses[indexPath.row].amount)"
        cell.expenseName.text = uncondensedListOfExpenses[indexPath.row].name
        cell.colorView.image = imageWithColor(uncondensedListOfExpenses[indexPath.row].tag.color)
        
        cell.colorView.layer.cornerRadius = cell.colorView.frame.size.width/2
        cell.colorView.clipsToBounds = true

        return cell
    }


    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            coreDataStack.context.deleteObject(self.uncondensedListOfExpenses[indexPath.row])
            coreDataStack.saveContext()

            self.uncondensedListOfExpenses.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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
    
    //creating UIImage with designated color
    func imageWithColor(color: UIColor) -> UIImage {
        var rect = CGRectMake(0, 0, 30, 30)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showExpense" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let destinationController = segue.destinationViewController as EditExpenseTVC
                destinationController.expenseItem = self.uncondensedListOfExpenses[indexPath.row]
                destinationController.coreDataStack = self.coreDataStack
            }
        }
    }
    
}
