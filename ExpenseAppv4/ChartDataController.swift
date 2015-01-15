//
//  chartDataController.swift
//  ExpenseAppv4
//
//  Created by Francis Young on 7/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ChartDataController {
    
    var coreDataStack: CoreDataStack!
    
    init (coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func getListOfTags() -> [Tag] {
        //get Tag list form coreDataStack
        let fetchRequest = NSFetchRequest(entityName: "Tag")
        var error: NSError? = nil
        
        let tagSort = NSSortDescriptor(key: "position", ascending: true)
        fetchRequest.sortDescriptors = [tagSort]
        
        return coreDataStack.context.executeFetchRequest(fetchRequest, error: &error) as [Tag]
    }
    
    func daily() -> (List: [[[Expense]]], labels: [String], tags: [Tag]) {
        
        //set up for items to return
        var expenseItemsToReturn = [[Expense]]()
        var stringDatesToReturn = [String]()
        
        //get a list of expenses
        var expenseItems = getExpenses()
        
        //set up calendar manipulation
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.locale = NSLocale.currentLocale()
        
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()

        
        var dayTracker = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions())!
        components.day = -1
        //println("This is day tracker \(dayTracker)")

        
        var dateSwitch: NSDateComponents
        
        //iterate through expenseItems and categorize by date
        var currentDayListOfExpenseItems = [Expense]()
        for i in 0..<expenseItems.count {
            
            //println(dateFormatter.stringFromDate(dayTracker))
            
            if expenseItems[i].dateAndTime.compare(dayTracker) == NSComparisonResult.OrderedDescending {
                currentDayListOfExpenseItems.append(expenseItems[i])
            } else {
                //iterate to find the latest date
                while expenseItems[i].dateAndTime.compare(dayTracker) == NSComparisonResult.OrderedAscending {

                    //append string to stringDatesToReturn
                    if stringDatesToReturn.count < 7 {
                        dateSwitch = calendar.components(.DayCalendarUnit | .WeekdayCalendarUnit, fromDate: dayTracker)
                        stringDatesToReturn.append(dateFormatter.shortWeekdaySymbols[(dateSwitch.weekday - 1)%7] as NSString)
                    } else {
                        var tempStringToReturn = (dateFormatter.stringFromDate(dayTracker) as NSString)
                        stringDatesToReturn.append(tempStringToReturn.substringWithRange(NSRange(location: 0, length: tempStringToReturn.length - 5)))
                    }
                    
                    dayTracker = calendar.dateByAddingComponents(components, toDate: dayTracker, options: nil)!
                    
                    //Manage ExpenseArray items
                    expenseItemsToReturn.append(currentDayListOfExpenseItems)
                    currentDayListOfExpenseItems = []
                }
                
                currentDayListOfExpenseItems.append(expenseItems[i])

            }
            
            if i == expenseItems.count - 1 {
                expenseItemsToReturn.append(currentDayListOfExpenseItems)
                
                //append string to stringDatesToReturn
                if stringDatesToReturn.count < 7 {
                    dateSwitch = calendar.components(.DayCalendarUnit | .WeekdayCalendarUnit, fromDate: dayTracker)
                    stringDatesToReturn.append(dateFormatter.shortWeekdaySymbols[(dateSwitch.weekday - 1)%7] as NSString)
                } else {
                    var tempStringToReturn = (dateFormatter.stringFromDate(dayTracker) as NSString)
                    stringDatesToReturn.append(tempStringToReturn.substringWithRange(NSRange(location: 0, length: tempStringToReturn.length - 5)))
                }
                dayTracker = calendar.dateByAddingComponents(components, toDate: dayTracker, options: nil)!

                
                currentDayListOfExpenseItems = []
            }
            
        }
        
        var newExpenseItemsToReturn = [[[Expense]]]()
        
        for i in 0..<expenseItemsToReturn.count {
            newExpenseItemsToReturn.append(organizeByTag(expenseItemsToReturn[i]))
        }
        
        /*
        println(dayTracker)
        println(stringDatesToReturn)
        println(expenseItemsToReturn)
        println(currentDayListOfExpenseItems.count)
        println("\n")
        
        
        for i in 0..<expenseItemsToReturn.count {
            let tempArray = expenseItemsToReturn[i] as [Expense]
            println("i = \(i)")
            for j in 0..<expenseItemsToReturn[i].count {
                println("j = \(j) with item \(tempArray[j].amount)")
            }
            println()

        }*/
        
        /*
        for i in 0..<newExpenseItemsToReturn.count {
            for j in 0..<newExpenseItemsToReturn[i].count {
                let tempArray = newExpenseItemsToReturn[i][j] as [Expense]
                for k in 0..<newExpenseItemsToReturn[i][j].count {
                    println ("i = \(i) with j = \(j) with item \(tempArray[k].amount)")
                }
            }
        }*/
        
        return (newExpenseItemsToReturn, stringDatesToReturn, getListOfTags())
    }
    
    func monthly() -> (List: [[[Expense]]], labels: [String], tags: [Tag]) {
        
        //set up for items to return
        var expenseItemsToReturn = [[Expense]]()
        var stringDatesToReturn = [String]()
        
        //get a list of expenses
        var expenseItems = getExpenses()
        
        
        //set up calendar manipulation
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.locale = NSLocale.currentLocale()

        
        let calendar = NSCalendar.currentCalendar()
        
        //get first day of month
        let componentsForMonth = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear, fromDate: NSDate())
        componentsForMonth.day = 1
        var firstDateOfMonth: NSDate = calendar.dateFromComponents(componentsForMonth)!
        
        let components = NSDateComponents()
        components.month = -1
        
        var dateSwitch: NSDateComponents
        
        //iterate through expenseItems and categorize by date
        var currentDayListOfExpenseItems = [Expense]()
        for i in 0..<expenseItems.count {
            
            if expenseItems[i].dateAndTime.compare(firstDateOfMonth) == NSComparisonResult.OrderedDescending {
                currentDayListOfExpenseItems.append(expenseItems[i])
            } else {
                //iterate to find the latest date
                while expenseItems[i].dateAndTime.compare(firstDateOfMonth) == NSComparisonResult.OrderedAscending {
                    
                    //append string to stringDatesToReturn
                    dateSwitch = calendar.components(.MonthCalendarUnit | .YearCalendarUnit , fromDate: firstDateOfMonth)
                    
                    let year =  String(dateSwitch.year) as NSString
                    
                    stringDatesToReturn.append("\(dateFormatter.shortMonthSymbols[(dateSwitch.month - 1)%12] as NSString) \(year.substringWithRange(NSRange(location: 2, length: year.length - 2)))")
                    firstDateOfMonth = calendar.dateByAddingComponents(components, toDate: firstDateOfMonth, options: nil)!
                    
                    //Manage ExpenseArray items
                    expenseItemsToReturn.append(currentDayListOfExpenseItems)
                    currentDayListOfExpenseItems = []
                }
                
                currentDayListOfExpenseItems.append(expenseItems[i])
                
            }
            
            if i == expenseItems.count - 1 {
                expenseItemsToReturn.append(currentDayListOfExpenseItems)
                
                //append string to stringDatesToReturn
                dateSwitch = calendar.components(.MonthCalendarUnit | .YearCalendarUnit , fromDate: firstDateOfMonth)
                
                let year =  String(dateSwitch.year) as NSString
                
                stringDatesToReturn.append("\(dateFormatter.shortMonthSymbols[(dateSwitch.month - 1)%12] as NSString) \(year.substringWithRange(NSRange(location: 2, length: year.length - 2)))")
                
                firstDateOfMonth = calendar.dateByAddingComponents(components, toDate: firstDateOfMonth, options: nil)!
                
                currentDayListOfExpenseItems = []
            }
            
        }
        
        var newExpenseItemsToReturn = [[[Expense]]]()
        
        for i in 0..<expenseItemsToReturn.count {
            newExpenseItemsToReturn.append(organizeByTag(expenseItemsToReturn[i]))
        }
        
        return (newExpenseItemsToReturn, stringDatesToReturn, getListOfTags())
    }

    func weekly() -> (List: [[[Expense]]], labels: [String], tags: [Tag]) {
        
        //set up for items to return
        var expenseItemsToReturn = [[Expense]]()
        var stringDatesToReturn = [String]()
        
        //get a list of expenses
        var expenseItems = getExpenses()
        
        //set up calendar manipulation
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.locale = NSLocale.currentLocale()
        
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.day = -1

        var weeklyTracker = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions())!
        
        var flip = true
        while flip {
            let dateTester = calendar.components(.DayCalendarUnit | .WeekdayCalendarUnit, fromDate: weeklyTracker)
            
            if (dateTester.weekday - 1)%7 == 1 {
                flip = false
            } else {
                weeklyTracker = calendar.dateByAddingComponents(components, toDate: weeklyTracker, options: nil)!
            }
        }
        
        components.day = -7
        
        var dateSwitch: NSDateComponents
        
        //iterate through expenseItems and categorize by date
        var currentDayListOfExpenseItems = [Expense]()
        for i in 0..<expenseItems.count {
            
            //println(dateFormatter.stringFromDate(dayTracker))
            
            if expenseItems[i].dateAndTime.compare(weeklyTracker) == NSComparisonResult.OrderedDescending {
                currentDayListOfExpenseItems.append(expenseItems[i])
            } else {
                //iterate to find the latest date
                while expenseItems[i].dateAndTime.compare(weeklyTracker) == NSComparisonResult.OrderedAscending {
                    
                    //append string to stringDatesToReturn
                    var tempStringToReturn = (dateFormatter.stringFromDate(weeklyTracker) as NSString)
                    stringDatesToReturn.append(tempStringToReturn.substringWithRange(NSRange(location: 0, length: tempStringToReturn.length - 5)))
                    weeklyTracker = calendar.dateByAddingComponents(components, toDate: weeklyTracker, options: nil)!
                    
                    //Manage ExpenseArray items
                    expenseItemsToReturn.append(currentDayListOfExpenseItems)
                    currentDayListOfExpenseItems = []
                }
                
                currentDayListOfExpenseItems.append(expenseItems[i])
                
            }
            
            if i == expenseItems.count - 1 {
                expenseItemsToReturn.append(currentDayListOfExpenseItems)
                
                //append string to stringDatesToReturn

                var tempStringToReturn = (dateFormatter.stringFromDate(weeklyTracker) as NSString)
                stringDatesToReturn.append(tempStringToReturn.substringWithRange(NSRange(location: 0, length: tempStringToReturn.length - 5)))

                weeklyTracker = calendar.dateByAddingComponents(components, toDate: weeklyTracker, options: nil)!
                
                
                currentDayListOfExpenseItems = []
            }
            
        }
        
        var newExpenseItemsToReturn = [[[Expense]]]()
        
        for i in 0..<expenseItemsToReturn.count {
            newExpenseItemsToReturn.append(organizeByTag(expenseItemsToReturn[i]))
        }
       
        return (newExpenseItemsToReturn, stringDatesToReturn, getListOfTags())
    }

    
    
    func organizeByTag(expensesToOrganize: [Expense]) -> [[Expense]] {
        var arrayToReturn = [[Expense]]()
        var listOfTags = getListOfTags()
        
        for i in 0..<listOfTags.count {
            arrayToReturn.append([Expense]())
        }
        
        for item in expensesToOrganize {
            if item.tag == nil {
                item.tag = listOfTags[0]
            }
            arrayToReturn[item.tag.position.integerValue].append(item)
        }
        
        return arrayToReturn
    }
    
    
    func getExpenses() -> [Expense] {
        //get Tag list form coreDataStack
        let fetchRequest = NSFetchRequest(entityName: "Expense")
        var error: NSError? = nil
        
        let expenseSort = NSSortDescriptor(key: "dateAndTime", ascending: false)
        fetchRequest.sortDescriptors = [expenseSort]
        
        var results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &error) as [Expense]
        
        /*
        for object in results {
            let expense = object as Expense
            println(expense.tag.position)
            println(expense.amount)
            println(expense.name)
            println(expense.dateAndTime)
            println(expense.coordinate?.latitude) //Issue here
            println("\n")
        }
        
        println("No. of objects = \(results.count)")*/
    
        return results
    }
    
    
    
}
