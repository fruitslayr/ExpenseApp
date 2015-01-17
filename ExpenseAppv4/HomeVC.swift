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

    @IBOutlet weak var barScrollView: UIScrollView!
    @IBOutlet weak var detailScrollView: UIScrollView!
    @IBOutlet weak var detailHeading: UIView!
    
    var coreDataStack: CoreDataStack!
    var chartDataController: ChartDataController!
    var expenseListForSegue: [[Expense]]!
    
    //opening settings
    var defaults = NSUserDefaults.standardUserDefaults()
    
    //User interactions
    var singleTap: UITapGestureRecognizer!
    var pinch: UIPinchGestureRecognizer!
    var singleTapForDetailBar: UITapGestureRecognizer!
    
    //variables to control zoom in and out feature
    var listOfGraphViews: [PNBarChart?] = [nil,nil,nil]
    var currentView: Int!
    
    var canPinch = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false

        self.navigationItem.title = "ExpenseTrackr"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AmericanTypewriter", size: 24)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        //initialize user interactions:
        singleTap = UITapGestureRecognizer(target: self, action: "handleTap:")
        pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        singleTapForDetailBar = UITapGestureRecognizer(target: self, action: "handleTapForDetailBar:")

    }

    override func viewWillAppear(animated: Bool) {
        
        if let views = barScrollView?.subviews {
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
        
        //remove user interactions:
        barScrollView.removeGestureRecognizer(singleTap)
        barScrollView.removeGestureRecognizer(pinch)
        detailScrollView.removeGestureRecognizer(singleTapForDetailBar)
        
        let instructions: Bool? = safetyCheckForExpense()
        
        if instructions == true {
            
            //Add user interactions:
            barScrollView.addGestureRecognizer(singleTap)
            barScrollView.addGestureRecognizer(pinch)
            detailScrollView.addGestureRecognizer(singleTapForDetailBar)
            
            chartDataController = ChartDataController(coreDataStack: coreDataStack)
            var graphDataToDisplay: (List: [[[Expense]]], labels: [String], tags: [Tag])!
            
            switch graphViewToLoad() {
            case 0:
                graphDataToDisplay = chartDataController.daily()
                currentView = 0
            case 1:
                graphDataToDisplay = chartDataController.weekly()
                currentView = 1
            case 2:
                graphDataToDisplay = chartDataController.monthly()
                currentView = 2
            default:
                graphDataToDisplay = chartDataController.daily()
                currentView = 0
            }
            
            listOfGraphViews[currentView] = createBarGraph(graphDataToDisplay)
            resizeScrollView(listOfGraphViews[currentView]!)
            barScrollView.addSubview(listOfGraphViews[currentView]!)
            
            var display = listOfGraphViews[currentView]?.chartData.List[0]
            
            updateDetailBar(display!)
            
        } else if instructions == false {
            let message = UILabel(frame: CGRectMake(10, 0, 300, 80))
            message.text = "There are no           expenses to display."
            message.textColor = appColor.defaultTintColor
            message.font = UIFont.systemFontOfSize(30)
            message.textAlignment = .Center
            message.numberOfLines = 4
            barScrollView.addSubview(message)
            
            let detailMessage = UILabel(frame: CGRectMake(30, 80, 260, 50))
            detailMessage.text = "Press the + button in the top right corner to add an expense."
            detailMessage.textColor = appColor.defaultTintColor
            detailMessage.font = UIFont.systemFontOfSize(15)
            detailMessage.textAlignment = .Center
            detailMessage.numberOfLines = 4
            barScrollView.addSubview(detailMessage)
        } else {
            let message = UILabel(frame: CGRectMake(10, 0, 300, 80))
            message.text = "There seems to            be a problem."
            message.textColor = appColor.defaultTintColor
            message.font = UIFont.systemFontOfSize(30)
            message.textAlignment = .Center
            message.numberOfLines = 4
            barScrollView.addSubview(message)
            
            let detailMessage = UILabel(frame: CGRectMake(30, 80, 260, 40))
            detailMessage.text = "Please contact us for further support."
            detailMessage.textColor = appColor.defaultTintColor
            detailMessage.font = UIFont.systemFontOfSize(15)
            detailMessage.textAlignment = .Center
            detailMessage.numberOfLines = 4
            barScrollView.addSubview(detailMessage)
            
            let button = UIButton(frame: CGRectMake(125, 130, 70, 30))
            button.setTitle("Email us", forState: .Normal)
            button.titleLabel?.font = UIFont.systemFontOfSize(15)
            button.layer.cornerRadius = 5.0
            button.layer.borderColor = appColor.headerTintColor.CGColor
            button.layer.borderWidth = 1.0
            button.setTitleColor(appColor.headerTintColor, forState: .Normal)
            button.addTarget(self, action: "errorEmail:", forControlEvents: .TouchUpInside)
            barScrollView.addSubview(button)
        }

    }

    //Methods to hangle user interaction:
    func handlePinch(event: UIPinchGestureRecognizer) {
        //println(event.velocity)
        
        if canPinch == false {return}
        
        canPinch = false
        
        if event.velocity > 0 {
            zoomIn()
        } else if event.velocity < 0 {
            zoomOut()
        }
    }
    
    func handleTap(gestureRecognizer:UITapGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(barScrollView)
        let graphView = barScrollView.subviews[0] as PNBarChart
        
        graphView.touchPoint(touchPoint) //****ISSUE HERE
    }
    
    func handleTapForDetailBar(gestureRecognizer:UITapGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(detailScrollView)
        if touchPoint.x > detailScrollView.contentSize.width - 95 {
            performSegueWithIdentifier("showExpenses", sender: detailScrollView)
        }
    }

    func createBarGraph(data: (List: [[[Expense]]], labels: [String], tags: [Tag])) -> PNBarChart {
        
        let currentBarChart = PNBarChart(frame: CGRectMake(0, 0, 640, 354))
        
        currentBarChart.backgroundColor = UIColor.clearColor()
        currentBarChart.labelMarginTop = 5.0
        
        //Set up size of views and controllers
        currentBarChart.frame = CGRectMake(0, 0, 46 * CGFloat(data.labels.count), 354)
        
        //change size according to requirements

        currentBarChart.xLabels = data.labels.reverse()
        currentBarChart.listOfExpenses = data.List.reverse()
        
        currentBarChart.strokeColors = []
        
        for tag in data.tags {
            currentBarChart.strokeColors.append(tag.color)
        }
        
        currentBarChart.strokeChart()
        currentBarChart.delegate = self
        currentBarChart.chartData = data
        
        return currentBarChart

    }
    
    //Resive scrollView for barGraph
    func resizeScrollView(view: UIView) {
        let width = view.frame.width
        
        if width > 320 {
            barScrollView.contentSize = CGSizeMake(width, 354)
            barScrollView.clipsToBounds = true
            
            barScrollView.contentOffset = CGPointMake(width-320, 0) //Results in the offset to to allow scrolling from right to left
        } else {
            barScrollView.contentSize = CGSizeMake(320, 354)
            barScrollView.clipsToBounds = true
            
            view.frame = CGRectMake(320 - view.frame.width, 0, view.frame.width, 354)
            
            barScrollView.contentOffset = CGPointMake(0, 0) //Results in the offset to to allow scrolling from right to left
        }
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
    
    @IBAction func zoomOut() {
        
        let viewToHide = barScrollView.subviews[0] as PNBarChart
        
        if currentView + 1 > 2 {
            self.canPinch = true
            return
        }
        
        if let viewToAdd = listOfGraphViews[currentView + 1] {
            viewToAdd.alpha = 0
            viewToAdd.transform = CGAffineTransformMakeScale(1.6, 1.6)
            barScrollView.insertSubview(viewToAdd, aboveSubview: viewToHide)
            updateDetailBar(viewToAdd.chartData.List[0])
        } else {
            
            var graphToDisplay: PNBarChart!
            
            if currentView + 1 == 1 {
                graphToDisplay = createBarGraph(chartDataController.weekly())
            } else if currentView + 1 == 2 {
                graphToDisplay = createBarGraph(chartDataController.monthly())
            }
            
            graphToDisplay.alpha = 0
            graphToDisplay.transform = CGAffineTransformMakeScale(1.6, 1.6)

            barScrollView.insertSubview(graphToDisplay, aboveSubview: viewToHide)
            updateDetailBar(graphToDisplay.chartData.List[0])
            
        }
        
        let viewToAnimate = barScrollView.subviews[1] as PNBarChart
        
        UIView.animateWithDuration(0.5, animations: {
            viewToAnimate.transform = CGAffineTransformMakeScale(1, 1)
            viewToAnimate.alpha = 1
            viewToHide.alpha = 0
            }, completion: {(bool) in
                self.listOfGraphViews[self.currentView] = viewToHide
                viewToHide.removeFromSuperview()
                self.currentView = self.currentView + 1
                self.canPinch = true
        })
        
    }
    
    
    @IBAction func zoomIn() {
        
        let viewToHide = barScrollView.subviews[0] as PNBarChart
        
        if currentView - 1 < 0 {
            self.canPinch = true
            return
        }
        
        if let viewToAdd = listOfGraphViews[currentView - 1] {
            viewToAdd.alpha = 0
            barScrollView.insertSubview(viewToAdd, belowSubview: viewToHide)
            updateDetailBar(viewToAdd.chartData.List[0])
        } else {
            
            var newView = UIView()
            var graphToDisplay: (List: [[[Expense]]], labels: [String], tags: [Tag])!

            if currentView - 1 == 1 {
                graphToDisplay = chartDataController.weekly()
            } else if currentView - 1 == 0 {
                graphToDisplay = chartDataController.daily()
            }
            
            newView.alpha = 0
            newView = createBarGraph(graphToDisplay)
            updateDetailBar(graphToDisplay.List[0])
            barScrollView.insertSubview(newView, belowSubview: viewToHide)
        }
        
        
        let viewToAnimate = barScrollView.subviews[0] as PNBarChart
        
        UIView.animateWithDuration(0.5, animations: {
            viewToHide.transform = CGAffineTransformMakeScale(1.6, 1.6)
            viewToHide.alpha = 0.0
            viewToAnimate.alpha = 1.0
            }, completion: {(bool) in
                self.listOfGraphViews[self.currentView] = viewToHide
                viewToHide.removeFromSuperview()
                self.currentView = self.currentView - 1
                self.canPinch = true
        })
        
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
