//
//  AppDelegate.swift
//  ExpenseAppTestv4
//
//  Created by Francis Young on 27/12/2014.
//  Copyright (c) 2014 Francis Young. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack: CoreDataStack = CoreDataStack()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.window?.backgroundColor = appColor.headerTintColor
        
        // Change navigation bar appearance
        UINavigationBar.appearance().barTintColor = appColor.headerTintColor
        
        UINavigationBar.appearance().tintColor = appColor.orangeColor
        UINavigationBar.appearance()
        UIBarButtonItem.appearance().tintColor = appColor.orangeColor
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60),
            forBarMetrics: .Default)
        
        if let barFont = UIFont(name: "Avenir-Medium", size: 24) {
            
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName:barFont]
        }
        
        
        //set image for title bar
        /*let titleBarImage = UIImage(named: "titleBar.png")
        UINavigationBar.appearance().setBackgroundImage(titleBarImage, forBarMetrics: .Default)
*/
        
        // Change status bar style
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        //set up core data stack for new user
        createTagsIfNeeded()
        
        //creating default settings of app
        createDefaultSettings()
        
        //Pass core data to child views
        let navController = window!.rootViewController as UINavigationController
        let viewController = navController.topViewController as HomeVC
        viewController.coreDataStack = coreDataStack
                
        return true
    }
    
    func createDefaultSettings() {
        //opening settings
        var defaults = NSUserDefaults(suiteName: "group.edu.self.ExpenseTrackr.Documents")
        
        //loading default settings
        if defaults?.objectForKey("currencySymbol") == nil {
            defaults?.setInteger(0, forKey: "currencySymbol")
            println("setInteger")
        }
        
        if defaults?.objectForKey("weeklyLimit") == nil {
            defaults?.setObject("200", forKey: "weeklyLimit")
        }
        
        if defaults?.objectForKey("defaultView") == nil {
            defaults?.setInteger(0, forKey: "defaultView")
        }
        
    }
    
    func createTagsIfNeeded() {
        let fetchRequest = NSFetchRequest(entityName: "Tag")
        var error: NSError? = nil
        
        let results = coreDataStack.context.countForFetchRequest(fetchRequest, error: &error)
        if results == 0 {
            var fetchError: NSError? = nil
            
            if let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &fetchError) {
                for object in results {
                    let tag = object as Tag
                    coreDataStack.context.deleteObject(tag)
                }
            }
            
            coreDataStack.saveContext()
            
            createTags()
        }
    }
    
    func createTags() {
        
        var error: NSError?
        let entity = NSEntityDescription.entityForName("Tag", inManagedObjectContext: coreDataStack.context)
        
        //Default tag 1
        let color = UIColor(red: 149/255, green: 192/255, blue: 232/255, alpha: 1)
        let position = 0
        let text = "Default Tag"
        
        let tag = Tag(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        
        tag.color = color
        tag.position = position
        tag.text = text
        
        // Default tag 2
        let color2 = UIColor(red: 222/255, green: 192/255, blue: 232/255, alpha: 1)
        let position2 = 1
        let text2 = "Example: Food & Drink"
     
        let tag2 = Tag(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        tag2.color = color2
        tag2.position = position2
        tag2.text = text2
        
        coreDataStack.saveContext()
        println("Imported 2 tags")
    }
    
    func testForExpense() {
        let fetchRequest = NSFetchRequest(entityName: "Expense")
        var error: NSError? = nil
        
        let results = coreDataStack.context.countForFetchRequest(fetchRequest, error: &error)
        if results > 0 {
            var fetchError: NSError? = nil
            
            if let results = coreDataStack.context.executeFetchRequest(fetchRequest, error: &fetchError) {
                for object in results {
                    let expense = object as Expense
                    println(expense.tag.text)
                    println(expense.amount)
                    println(expense.name)
                    println(expense.dateAndTime)
                    println(expense.coordinate?.latitude) //Issue here
                    println("\n")
                }
            }
            
        }

    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

