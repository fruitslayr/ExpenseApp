//
//  ManageTagsTVC.swift
//  ExpenseAppTestv4
//
//  Created by Francis Young on 27/12/2014.
//  Copyright (c) 2014 Francis Young. All rights reserved.
//

import UIKit
import CoreData

class ManageTagsTVC: UITableViewController, ColorPickerDelegate {
    
    var listOfTags: [Tag] = []
    var coreDataStack: CoreDataStack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get Tag list form coreDataStack
        let fetchRequest = NSFetchRequest(entityName: "Tag")
        var error: NSError? = nil
        
        let tagSort = NSSortDescriptor(key: "position", ascending: true)
        fetchRequest.sortDescriptors = [tagSort]
        
        listOfTags = coreDataStack.context.executeFetchRequest(fetchRequest, error: &error) as [Tag]
        
        //Formatting the tableViewFooter
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //cell row height
        self.tableView.rowHeight = 44
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //creating UIImage with designated color
    func imageWithColor(color: UIColor) -> UIImage {
        var rect = CGRectMake(0, 0, 34, 34)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
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
        return self.editing ? listOfTags.count + 1 : listOfTags.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as customTableViewCell
        
        if indexPath.row == listOfTags.count {
            cell.tagLabel.text = "Add a new tag..."
            cell.colorView.image = UIImage(named: "add.png")
        } else {
            cell.tagLabel.text = listOfTags[indexPath.row].text
            cell.colorView.image = imageWithColor(listOfTags[indexPath.row].color as UIColor)
        }
        
        cell.colorView.layer.cornerRadius = cell.colorView.frame.size.width/2
        cell.colorView.clipsToBounds = true
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //////////////////////////////////////////////////////
            //////check to see if they really want to delete//////
            //////////////////////////////////////////////////////
            
            // Create an option menu as an action sheet
            let optionMenu = UIAlertController(title: "Warning!", message: "Deleting this tag will result in all of the expense items with this tag being set to the 'Default tag'. Do you still want to delete this tag?", preferredStyle: .Alert)
            
            // Add Delete action to the menu
            let deleteRow = { (action:UIAlertAction!) -> Void in
                // Delete the row from the data source
                self.coreDataStack.context.deleteObject(self.listOfTags[indexPath.row])
                self.listOfTags.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                self.updateTags()
            }

            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: deleteRow)
            optionMenu.addAction(deleteAction)

            // Add Cancel action to the menu
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            optionMenu.addAction(cancelAction)
            
            self.presentViewController(optionMenu, animated: true, completion: nil)
            
        } else if editingStyle == .Insert {
            
            let newTag = NSEntityDescription.insertNewObjectForEntityForName("Tag", inManagedObjectContext: coreDataStack.context) as Tag
            
            newTag.text = "New Tag"
            newTag.color = UIColor(red: 209/255, green: 209/255, blue: 209/255, alpha: 1)
            newTag.position = listOfTags.count
            
            listOfTags.append(newTag)
            
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.listOfTags.count - 1, inSection: 0)], withRowAnimation: .Top)
            self.tableView.endUpdates()
            //THERE IS A BUG IN THE CODE HERE!!// -> requre double tap to delete cell
            
            self.coreDataStack.saveContext()
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if (indexPath.row == 0) {
            return .None
        }  else if (indexPath.row == listOfTags.count) {
            return .Insert
        } else if self.tableView.editing {
            return .Delete
        } else {
            return .None
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated:animated)
        self.tableView.setEditing(editing, animated: animated)
        
        if (editing) {
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: listOfTags.count, inSection: 0)], withRowAnimation: .Left)
            self.tableView.endUpdates()
        } else {
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: listOfTags.count, inSection: 0)], withRowAnimation: .Left)
            self.tableView.endUpdates()
        }
        
    }
    
    //Allow reordering of tablView
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else if indexPath.row == listOfTags.count {
            return false
        } else {
            return true
        }
    }

    //prevent reordering from displacing 'Default cell' or 'Add new cell' label
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if proposedDestinationIndexPath.row == 0 || proposedDestinationIndexPath.row == listOfTags.count {
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }
    
    //facilitate placing cell back into source
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let item: Tag = listOfTags[sourceIndexPath.row]
        listOfTags.removeAtIndex(sourceIndexPath.row)
        listOfTags.insert(item, atIndex: destinationIndexPath.row)
        updateTags()
    }
    
    //ColorPickerViewController delegate
    func updateTags(controller: ColorPickerViewController, tag: String, color: UIColor, index:NSIndexPath) {
        listOfTags[index.row].text = tag
        listOfTags[index.row].color = color
        self.tableView.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.None)
        self.coreDataStack.saveContext()
    }
    
    //  preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "showColorPicker" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let destinationController = segue.destinationViewController as ColorPickerViewController
                destinationController.colorPassed = self.listOfTags[indexPath.row].color as UIColor
                destinationController.textPassed = self.listOfTags[indexPath.row].text
                destinationController.index = indexPath
                destinationController.delegate = self
            }
        }
    }
    
    func updateTags() {
        for i in 0..<listOfTags.count {
            listOfTags[i].position = i
        }
        self.coreDataStack.saveContext()
    }

}
