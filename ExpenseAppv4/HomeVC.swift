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

class HomeVC: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var graphView: UIView!
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
    var listOfGraphViewControllers: [CollectionViewController?] = [nil,nil,nil]
    var currentViewController: Int!
    
    var canPinch = true
    
    //Limit details
    var limitLine = UIImageView()
    var limitLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hasViewedWalkthrough = defaults.boolForKey("hasViewedWalkthrough")
        
        if hasViewedWalkthrough == false {
            if let pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageVC") as? PageVC {
                self.presentViewController(pageViewController, animated: false, completion: nil)
            }
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        
        //create limit line
        limitLine = drawLimit()

    }

    override func viewWillAppear(animated: Bool) {
        
        if let views = graphView?.subviews {
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
        graphView.removeGestureRecognizer(pinch)
        
        let instructions: Bool? = safetyCheckForExpense()
        
        if instructions == true {
            
            //Add user interactions:
            graphView.addGestureRecognizer(pinch)
            
            chartDataController = ChartDataController(coreDataStack: coreDataStack)
            var graphDataToDisplay: (List: [[[Expense]]], labels: [String], tags: [Tag])!
            
            switch graphViewToLoad() {
            case 0:
                graphDataToDisplay = chartDataController.daily()
                currentViewController = 0
            case 1:
                graphDataToDisplay = chartDataController.weekly()
                currentViewController = 1
            case 2:
                graphDataToDisplay = chartDataController.monthly()
                currentViewController = 2
            default:
                graphDataToDisplay = chartDataController.daily()
                currentViewController = 0
            }

            listOfGraphViewControllers[currentViewController] = createBarGraph(graphDataToDisplay, viewType: currentViewController)
            graphView.addSubview(listOfGraphViewControllers[currentViewController]!.collectionView!)
            
            /*
            let barChart = scrollView.subviews[0] as PNBarChart
            barChart.selectBar(0)
            */
            
            addLimitDetails()
            
        } else if instructions == false {
            let message = UILabel(frame: CGRectMake(10, 0, 300, 80))
            message.text = "There are no           expenses to display."
            message.textColor = appColor.defaultTintColor
            message.font = UIFont.systemFontOfSize(30)
            message.textAlignment = .Center
            message.numberOfLines = 4
            graphView.addSubview(message)
            
            let detailMessage = UILabel(frame: CGRectMake(30, 80, 260, 50))
            detailMessage.text = "Press the + button in the top right corner to add an expense."
            detailMessage.textColor = appColor.defaultTintColor
            detailMessage.font = UIFont.systemFontOfSize(15)
            detailMessage.textAlignment = .Center
            detailMessage.numberOfLines = 4
            graphView.addSubview(detailMessage)
        } else {
            let message = UILabel(frame: CGRectMake(10, 0, 300, 80))
            message.text = "There seems to            be a problem."
            message.textColor = appColor.defaultTintColor
            message.font = UIFont.systemFontOfSize(30)
            message.textAlignment = .Center
            message.numberOfLines = 4
            graphView.addSubview(message)
            
            let detailMessage = UILabel(frame: CGRectMake(30, 80, 260, 40))
            detailMessage.text = "Please contact us for further support."
            detailMessage.textColor = appColor.defaultTintColor
            detailMessage.font = UIFont.systemFontOfSize(15)
            detailMessage.textAlignment = .Center
            detailMessage.numberOfLines = 4
            graphView.addSubview(detailMessage)
            
            let button = UIButton(frame: CGRectMake(125, 130, 70, 30))
            button.setTitle("Email us", forState: .Normal)
            button.titleLabel?.font = UIFont.systemFontOfSize(15)
            button.layer.cornerRadius = 5.0
            button.layer.borderColor = appColor.headerTintColor.CGColor
            button.layer.borderWidth = 1.0
            button.setTitleColor(appColor.headerTintColor, forState: .Normal)
            button.addTarget(self, action: "errorEmail:", forControlEvents: .TouchUpInside)
            graphView.addSubview(button)
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
    

    /*
    func handleTap(gestureRecognizer:UITapGestureRecognizer) {
        
        let scrollView = listOfGraphScrollViews[currentScrollView]! as UIScrollView
        let barChart = scrollView.subviews[0] as PNBarChart

        let touchPoint = gestureRecognizer.locationInView(barChart)
        barChart.touchPoint(touchPoint)
    }


    func handleTapForDetailBar(gestureRecognizer:UITapGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(detailScrollView)
        if touchPoint.x > detailScrollView.contentSize.width - 95 {
            performSegueWithIdentifier("showExpenses", sender: detailScrollView)
        }
    }
    */


    func createBarGraph(data: (List: [[[Expense]]], labels: [String], tags: [Tag]), viewType: Int) -> CollectionViewController {
        
        let collectionViewLayout = UICollectionViewLayout()
        collectionViewLayout
        
        let currentBarChart = CollectionViewController(collectionViewLayout: this)
        
        currentBarChart.viewType = viewType
        
        currentBarChart.listOfLabels = data.labels.reverse()
        currentBarChart.listOfExpenses = data.List.reverse()
        
        currentBarChart.strokeColors = []
        currentBarChart.yValueMax = CGFloat((genLimitAmount(viewType) / 3) * 4)
        
        for tag in data.tags {
            currentBarChart.strokeColors.append(tag.color)
        }
        
        currentBarChart.chartData = data
        
        return currentBarChart

    }
    
    //Handle transition of limitDetails to view
    func addLimitDetails() {
        
        limitLabel = labelLimit()
        
        graphView.addSubview(limitLabel)
        graphView.addSubview(limitLine)
        
        UIView.animateWithDuration(0.3, animations: {
            self.limitLine.alpha = 0.4
            self.limitLabel.alpha = 0.6
            })
    }
    
    func removeLimitDetails() {
        
        UIView.animateWithDuration(0.3, animations: {
            self.limitLine.alpha = 0
            self.limitLabel.alpha = 0
            }, completion: {(bool) in
                self.limitLabel.removeFromSuperview()
                self.limitLine.removeFromSuperview()
            })
        
    }
    
    //Handle display of limit
    func drawLimit() -> UIImageView{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 1), false, 0)
        
        //Get current image context
        let context = UIGraphicsGetCurrentContext()
        
        // Perform the drawing
        CGContextSetLineWidth(context, 1)
        CGContextSetStrokeColorWithColor(context,
            appColor.limitLineColor.CGColor)
        CGContextMoveToPoint(context, 0, 0.5)
        CGContextAddLineToPoint(context, 320, 0.5)
        CGContextStrokePath(context)
        
        // Retrieve the drawn image
        let imageView = UIImageView(frame: CGRectMake(0, 93, 320, 1))
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        imageView.alpha = 0.0
        
        UIGraphicsEndImageContext()
        
        return imageView
    }
    
    func labelLimit() -> UILabel {
        let myText: UILabel = UILabel(frame: CGRectMake(0, 0 , 100, 25))
        myText.font = UIFont.systemFontOfSize(16)
        
        //let someDoubleFormat = ".2"
        //myText.text = "\(getCurrencySymbol()) \(genLimitAmount(currentScrollView).format(someDoubleFormat))"
        myText.text = "\(getCurrencySymbol()) \(Int(round(genLimitAmount(currentViewController))))"
        myText.textColor = appColor.limitLabelColor
        myText.sizeToFit()
        myText.alpha = 0
        
        //For testing purposes
        //myText.layer.borderWidth = 1
        //myText.layer.borderColor = UIColor.redColor().CGColor
                
        myText.frame = CGRectMake(10, 91 - myText.frame.size.height , myText.frame.size.width, myText.frame.size.height)
        
        return myText
    }
    
    func genLimitAmount(viewType: Int) -> Double {
        var limitPerDay: Double = 0
        
        if let weeklyLimitIsNotNil = defaults.objectForKey("weeklyLimit") as? String {
            limitPerDay = (defaults.objectForKey("weeklyLimit") as NSString).doubleValue / 7
        }
        
        switch viewType {
        case 0:
            return limitPerDay
        case 1:
            return limitPerDay*7
        case 2:
            return limitPerDay*30
        default:
            println("Error")
            return limitPerDay
        }
    }
    
    /*
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
    }*/
    
    @IBAction func zoomOut() {
        
        let viewToHide = graphView.subviews[0] as UICollectionView
        
        if currentViewController + 1 > 2 {
            self.canPinch = true
            return
        }
        
        removeLimitDetails()
        
        if let viewToAdd = listOfGraphViewControllers[currentViewController + 1]?.collectionView {
            viewToAdd.alpha = 0
            viewToAdd.transform = CGAffineTransformMakeScale(1.3, 1.3)
            graphView.insertSubview(viewToAdd, aboveSubview: viewToHide)
            
            /*
            let barChart = scrollViewToAdd.subviews[0] as PNBarChart
            barChart.selectBar(0)
            */
        } else {
            
            var graphController: CollectionViewController!
            
            if currentViewController + 1 == 1 {
                graphController = createBarGraph(chartDataController.weekly(), viewType: currentViewController + 1)
            } else if currentViewController + 1 == 2 {
                graphController = createBarGraph(chartDataController.monthly(), viewType: currentViewController + 1)
            }
            
            let graphToDisplay = graphController.collectionView!
            graphToDisplay.alpha = 0
            graphToDisplay.transform = CGAffineTransformMakeScale(1.3, 1.3)
            graphView.insertSubview(graphToDisplay, aboveSubview: viewToHide)
            
            //let barChart = newScrollView.subviews[0] as PNBarChart
            //barChart.selectBar(0)
            
        }
        
        let viewToAnimate = graphView.subviews[1] as UICollectionView
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: nil,  animations: {
            viewToAnimate.transform = CGAffineTransformMakeScale(1, 1)
            viewToAnimate.alpha = 1
            viewToAnimate.alpha = 0
            }, completion: {(bool) in
                self.listOfGraphViewControllers[self.currentViewController] = viewToHide.delegate! as? CollectionViewController
                viewToHide.removeFromSuperview()
                self.listOfGraphViewControllers[self.currentViewController + 1] = viewToAnimate.delegate! as? CollectionViewController
                self.currentViewController = self.currentViewController + 1
                
                self.canPinch = true
                self.addLimitDetails()
                
        })
        
    }
    
    
    @IBAction func zoomIn() {
        
        let viewToHide = graphView.subviews[0] as UICollectionView
        var viewToAnimate: UICollectionView!
        
        if currentViewController - 1 < 0 {
            self.canPinch = true
            return
        }
        
        removeLimitDetails()
        
        if let viewToAdd = listOfGraphViewControllers[currentViewController - 1]!.collectionView? {
            viewToAdd.alpha = 0
            graphView.insertSubview(viewToAdd, belowSubview: viewToHide)
            
            /*let barChart = viewToAdd.subviews[0] as PNBarChart
            barChart.selectBar(0)*/
            
            viewToAnimate = graphView.subviews[0] as UICollectionView
        } else {
            
            var graphController: CollectionViewController!
            
            if currentViewController - 1 == 1 {
                graphController = createBarGraph(chartDataController.weekly(), viewType: currentViewController - 1)
            } else if currentViewController - 1 == 0 {
                graphController = createBarGraph(chartDataController.daily(), viewType: currentViewController - 1)
            }
            
            let graphToDisplay = graphController.collectionView!
            graphToDisplay.alpha = 0
            graphView.insertSubview(graphToDisplay, aboveSubview: viewToHide)
            
            /*let barChart = newScrollView.subviews[0] as PNBarChart
            barChart.selectBar(0)*/
            
            viewToAnimate = graphView.subviews[1] as UICollectionView
            
        }
        
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: nil, animations: {
            viewToHide.transform = CGAffineTransformMakeScale(1.3, 1.3)
            viewToHide.alpha = 0.0
            viewToAnimate.alpha = 1.0
            }, completion: {(bool) in
                self.listOfGraphViewControllers[self.currentViewController] = viewToHide.delegate! as? CollectionViewController
                viewToHide.removeFromSuperview()
                self.listOfGraphViewControllers[self.currentViewController - 1] = viewToAnimate.delegate! as? CollectionViewController
                self.currentViewController = self.currentViewController - 1

                self.canPinch = true
                self.addLimitDetails()
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
