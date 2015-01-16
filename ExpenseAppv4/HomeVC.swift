//
//  HomeVC.swift
//  ExpenseAppTestv4
//
//  Created by Francis Young on 27/12/2014.
//  Copyright (c) 2014 Francis Young. All rights reserved.
//

import UIKit
import MessageUI
import CoreData

class HomeVC: UIViewController, PNChartDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var barGraph: UIView!
    @IBOutlet weak var barScrollView: UIScrollView!
    
    @IBOutlet weak var detailScrollView: UIScrollView!
    @IBOutlet weak var detailHeading: UIView!
    
    var barChart = PNBarChart(frame: CGRectMake(0, 0, 640, 354))
    var coreDataStack: CoreDataStack!
    
    var chartDataController: ChartDataController!
    var graphDataToDisplay: (List: [[[Expense]]], labels: [String], tags: [Tag])!

    var expenseListForSegue: [[Expense]]!
    
    //opening settings
    var defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false

        self.navigationItem.title = "ExpenseTrackr"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AmericanTypewriter", size: 24)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]

    }

    override func viewWillAppear(animated: Bool) {
        
        if let views = barGraph?.subviews {
            for view in views {
                view.removeFromSuperview()
            }
        }
        
        if let views = detailScrollView?.subviews {
            for view in views {
                view.removeFromSuperview()
            }
        }
        
        if let views = detailHeading?.subviews {
            for view in views {
                view.removeFromSuperview()
            }
        }
        
        let instructions: Bool? = safetyCheckForExpense()
        
        if instructions == true {
            
            let singleTap = UITapGestureRecognizer(target: self, action: "handleTap:")
            barScrollView.addGestureRecognizer(singleTap)

            let pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
            barScrollView.addGestureRecognizer(pinch)
            
            let singleTapForDetailBar = UITapGestureRecognizer(target: self, action: "handleTapForDetailBar:")
            detailScrollView.addGestureRecognizer(singleTapForDetailBar)
            
            chartDataController = ChartDataController(coreDataStack: coreDataStack)
            
            switch graphViewToLoad() {
            case 0:
                graphDataToDisplay = chartDataController.daily()
            case 1:
                graphDataToDisplay = chartDataController.weekly()
            case 2:
                graphDataToDisplay = chartDataController.monthly()
            default:
                graphDataToDisplay = chartDataController.daily()
            }
            
            updateDetailBar(graphDataToDisplay.List[0])
            
            createBarGraph(graphDataToDisplay)
            barScrollView.addSubview(barGraph)
        } else if instructions == false {
            let message = UILabel(frame: CGRectMake(10, 0, 300, 80))
            message.text = "There are no           expenses to display."
            message.textColor = appColor.defaultTintColor
            message.font = UIFont.systemFontOfSize(30)
            message.textAlignment = .Center
            message.numberOfLines = 4
            barGraph.addSubview(message)
            
            let detailMessage = UILabel(frame: CGRectMake(30, 80, 260, 50))
            detailMessage.text = "Press the + button in the top right corner to add an expense."
            detailMessage.textColor = appColor.defaultTintColor
            detailMessage.font = UIFont.systemFontOfSize(15)
            detailMessage.textAlignment = .Center
            detailMessage.numberOfLines = 4
            barGraph.addSubview(detailMessage)
        } else {
            let message = UILabel(frame: CGRectMake(10, 0, 300, 80))
            message.text = "There seems to            be a problem."
            message.textColor = appColor.defaultTintColor
            message.font = UIFont.systemFontOfSize(30)
            message.textAlignment = .Center
            message.numberOfLines = 4
            barGraph.addSubview(message)
            
            let detailMessage = UILabel(frame: CGRectMake(30, 80, 260, 40))
            detailMessage.text = "Please contact us for further support."
            detailMessage.textColor = appColor.defaultTintColor
            detailMessage.font = UIFont.systemFontOfSize(15)
            detailMessage.textAlignment = .Center
            detailMessage.numberOfLines = 4
            barGraph.addSubview(detailMessage)
            
            let button = UIButton(frame: CGRectMake(125, 130, 70, 30))
            button.setTitle("Email us", forState: .Normal)
            button.titleLabel?.font = UIFont.systemFontOfSize(15)
            button.layer.cornerRadius = 5.0
            button.layer.borderColor = appColor.headerTintColor.CGColor
            button.layer.borderWidth = 1.0
            button.setTitleColor(appColor.headerTintColor, forState: .Normal)
            button.addTarget(self, action: "errorEmail:", forControlEvents: .TouchUpInside)
            barGraph.addSubview(button)
        }

    }

    func handlePinch(gestureRecognizer:UIPinchGestureRecognizer) {
        //println(gestureRecognizer.velocity)
    }
    
    func handleTap(gestureRecognizer:UITapGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(barGraph)
        barChart.touchPoint(touchPoint)
    }
    
    func handleTapForDetailBar(gestureRecognizer:UITapGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(detailScrollView)
        if touchPoint.x > detailScrollView.contentSize.width - 95 {
            performSegueWithIdentifier("showExpenses", sender: detailScrollView)
        }
    }

    func createBarGraph(data: (List: [[[Expense]]], labels: [String], tags: [Tag])) {
        
        barChart.backgroundColor = UIColor.clearColor()
        barChart.labelMarginTop = 5.0
        
        //Set up size of views and controllers
        barChart.frame = CGRectMake(0, 0, 46 * CGFloat(data.labels.count), 354)
        barScrollView.contentSize = CGSizeMake(46 * CGFloat(data.labels.count), 354)
        barScrollView.clipsToBounds = true
        barScrollView.contentOffset = CGPointMake(46 * CGFloat(data.labels.count)-320, 0) //Results in the offset to to allow scrolling from right to left

        
        //change size according to requirements

        barChart.xLabels = data.labels.reverse()
        barChart.listOfExpenses = data.List.reverse()
        
        barChart.strokeColors = []
        
        for tag in data.tags {
            barChart.strokeColors.append(tag.color)
        }
        
        barChart.strokeChart()
        
        barChart.delegate = self
        barGraph.addSubview(barChart)
    }
    
    //PNBarChart delegate methods
    func userClickedOnLineKeyPoint(point: CGPoint, lineIndex: Int, keyPointIndex: Int){}
    
    func userClickedOnLinePoint(point: CGPoint, lineIndex: Int){}
    
    func userClickedOnBar(expenseList: [[Expense]])
    {
        updateDetailBar(expenseList)
    }
    
    func updateDetailBar(expenseList: [[Expense]]) {
        let detailBarController = DetailBarController(expenseList: expenseList, coreDataStack: coreDataStack)
        expenseListForSegue = expenseList
        
        detailScrollView.contentOffset = CGPointMake(0, 0)
        detailScrollView.clipsToBounds = true
        
        //Testing purposes
        //detailScrollView.layer.borderWidth = 1
        //detailScrollView.layer.borderColor = UIColor.blackColor().CGColor
        
        for view in detailScrollView.subviews {
            view.removeFromSuperview()
        }
        detailScrollView.addSubview(detailBarController.report())
        
        for view in detailHeading.subviews {
            view.removeFromSuperview()
        }
        detailHeading.addSubview(detailBarController.heading())
        
        
        //resize contentsize of uiscrollview to subviews
        var contentRect: CGRect = CGRectZero;
        
        for view in self.detailScrollView.subviews {
            contentRect = CGRectUnion(contentRect, view.frame)
        }
        self.detailScrollView.contentSize = contentRect.size
    }
    
    func graphViewToLoad() -> Int {
        if let defaultViewIsNotNil = defaults.objectForKey("defaultView") as? Int {
            return defaults.objectForKey("defaultView") as Int
        } else {
            return 0
        }
    }
    
    func safetyCheckForExpense() -> Bool? {
        let fetchRequest = NSFetchRequest(entityName: "Expense")
        var error: NSError? = nil
        let results = coreDataStack.context.countForFetchRequest(fetchRequest, error: &error)
        
        if results == 0 {
            return false
        } else if error != nil {
            println("Error is \(error)")
            return nil
        } else {
            return true
        }

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toNavControllerSettings" {
            let navController = segue.destinationViewController as UINavigationController
            let destinationController = navController.topViewController as SettingsTVC
            destinationController.coreDataStack = self.coreDataStack
        } else if segue.identifier == "toNavControllerNewExpense" {
            let navController = segue.destinationViewController as UINavigationController
            let destinationController = navController.topViewController as NewExpenseTVC
            destinationController.coreDataStack = self.coreDataStack
        } else if segue.identifier == "showExpenses" {
            let destinationController = segue.destinationViewController as DetailBarTVC
            destinationController.coreDataStack = self.coreDataStack
            destinationController.condensedListOfExpenses = expenseListForSegue
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(segue:UIStoryboardSegue) {}

    @IBAction func errorEmail() {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.navigationBar.tintColor = UIColor.whiteColor()
        
        mailComposerVC.setToRecipients(["fruitslayr@icloud.com"])
        mailComposerVC.setSubject("Error Report")
        
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
    
    
}
