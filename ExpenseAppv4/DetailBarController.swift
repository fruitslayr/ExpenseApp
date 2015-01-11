//
//  DetailBarController.swift
//  ExpenseAppv4
//
//  Created by Francis Young on 11/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self)
    }
}

class DetailBarController {
    
    let expenseList: [[Expense]]
    let coreDataStack: CoreDataStack
    let defaults = NSUserDefaults.standardUserDefaults()
    
    init(expenseList: [[Expense]], coreDataStack:CoreDataStack) {
        self.expenseList = expenseList
        self.coreDataStack = coreDataStack
    }
    
    func heading() -> UIView {
        let viewToReturn = UIView(frame: CGRectMake(0, 0, 320, 100))
        
        let totalLabel = UILabel(frame: CGRectMake(0 , 30, 320, 40))
        let someDoubleFormat = ".2"
        totalLabel.text = "\(getCurrencySymbol()) \(getTotalExpense().format(someDoubleFormat))"
        
        totalLabel.font = UIFont.systemFontOfSize(40)
        totalLabel.textAlignment = NSTextAlignment.Center
        viewToReturn.addSubview(totalLabel)
        
        return viewToReturn
    }
    
    func report() -> UIView {
        let viewToReturn = UIView()

        //For testing purposes only
        //viewToReturn.layer.borderColor = UIColor.redColor().CGColor
        //viewToReturn.layer.borderWidth = 1
        
        var positionTracker: CGFloat = 0
        var summedByTags = summedExpenseByTags()
        
        for tag in getListOfTags() {
            var myIcon: UIImageView = UIImageView(image: imageWithColor(tag.color as UIColor))
            myIcon.frame = CGRectMake(positionTracker + 10, 10, 30, 30)
            myIcon.layer.cornerRadius = myIcon.frame.size.width/2
            myIcon.clipsToBounds = true
            
            positionTracker += 50
            
            var myText: UILabel = UILabel(frame: CGRectMake(positionTracker, 0 , 100, 25))
            myText.font = UIFont.systemFontOfSize(14)
            myText.text = tag.text
            myText.sizeToFit()
            var myPrice: UILabel = UILabel(frame: CGRectMake(positionTracker, 25, 100, 25))
            myPrice.font = UIFont.systemFontOfSize(14)
            myPrice.textColor = appColor.defaultTintColor
            
            let someDoubleFormat = ".2"
            myPrice.text = "\(getCurrencySymbol()) \(summedByTags[tag.position.integerValue].format(someDoubleFormat))"
            myPrice.sizeToFit()

            var maxWidth: CGFloat = 0
            
            if myText.frame.size.width > myPrice.frame.size.width {
                maxWidth = myText.frame.size.width
            } else {
                maxWidth = myPrice.frame.size.width
            }
            
            let heightAdjustment = (50 - myText.frame.size.height * 2)/2
            myText.frame = CGRectMake(positionTracker, heightAdjustment, maxWidth, myText.frame.size.height)
            myPrice.frame = CGRectMake(positionTracker, heightAdjustment + myText.frame.size.height, maxWidth, myPrice.frame.size.height)
            
            positionTracker += maxWidth + 10
            
            viewToReturn.addSubview(myIcon)
            viewToReturn.addSubview(myText)
            viewToReturn.addSubview(myPrice)
        }
        
        let finalView = UIView(frame: CGRectMake(positionTracker + 10, 0, 90, 50))
        
        var seeMoreLabel = UILabel(frame: CGRectMake(0, 0, 65, 50))
        seeMoreLabel.text = "See more"
        seeMoreLabel.font = UIFont.systemFontOfSize(14)
        seeMoreLabel.textAlignment = NSTextAlignment.Right
        seeMoreLabel.textColor = appColor.defaultTintColor
        finalView.addSubview(seeMoreLabel)
        
        var accessoryView = MSCellAccessory(type: MSCellAccessoryType.FLAT_DISCLOSURE_INDICATOR, color: appColor.defaultTintColor)
        accessoryView.frame = CGRectMake(50, 10, 30 , 30)
        finalView.addSubview(accessoryView)
        viewToReturn.addSubview(finalView)
        
        positionTracker += 95
        viewToReturn.frame = CGRectMake(0, 0, positionTracker, 50)
        
        return viewToReturn
    }
    
    func showMore() {
        println("Runs2")
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
    
    func getTotalExpense() -> Double {
        var sumToReturn = Double()
        
        for i in summedExpenseByTags() {
            sumToReturn += i
        }
        
        return sumToReturn
    }
    
    func getListOfTags() -> [Tag] {
        //get Tag list form coreDataStack
        let fetchRequest = NSFetchRequest(entityName: "Tag")
        var error: NSError? = nil
        
        let tagSort = NSSortDescriptor(key: "position", ascending: true)
        fetchRequest.sortDescriptors = [tagSort]
        
        return coreDataStack.context.executeFetchRequest(fetchRequest, error: &error) as [Tag]
    }
    
    func summedExpenseByTags() -> [Double] {
        var listToReturn: [Double] = []
        
        for i in 0..<expenseList.count {
            
            var count:Double = 0
            
            for j in 0..<expenseList[i].count {
                count += expenseList[i][j].amount.doubleValue
            }
            
            listToReturn.append(count)

        }

        return listToReturn
    }

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
    
}