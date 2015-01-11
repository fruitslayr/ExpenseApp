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
    
    var defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        println("runs")
        
        for array in condensedListOfExpenses {
            for item in array {
                uncondensedListOfExpenses.append(item)
            }
        }
        
        /*
        let expenseSort = NSSortDescriptor(key: "dateAndTime", ascending: false)
        uncondensedListOfExpenses.sort(<#isOrderedBefore: (T, T) -> Bool##(T, T) -> Bool#>)
        */
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

    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

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
    
    //creating UIImage with designated color
    func imageWithColor(color: UIColor) -> UIImage {
        var rect = CGRectMake(0, 0, 30, 30)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    
}
