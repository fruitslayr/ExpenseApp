//
//  HomeVC.swift
//  ExpenseAppTestv4
//
//  Created by Francis Young on 27/12/2014.
//  Copyright (c) 2014 Francis Young. All rights reserved.
//

import UIKit
import CoreData

class HomeVC: UIViewController, PNChartDelegate {

    @IBOutlet weak var barGraph: UIView!
    @IBOutlet weak var barScrollView: UIScrollView!
    
    @IBOutlet weak var detailScrollView: UIScrollView!
    @IBOutlet weak var detailBar: UIView!
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
        
        let singleTap = UITapGestureRecognizer(target: self, action: "handleTap:")
        let pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        barScrollView.addGestureRecognizer(singleTap)
        barScrollView.addGestureRecognizer(pinch)
        self.automaticallyAdjustsScrollViewInsets = false
        
        let singleTap2 = UITapGestureRecognizer(target: self, action: "handleTap2:")
        detailScrollView.addGestureRecognizer(singleTap2)
        
    }

    override func viewWillAppear(animated: Bool) {
        
        let instructions: Bool? = safetyCheckForExpense()
        
        if instructions == true {
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
    
    func handleTap2(gestureRecognizer:UITapGestureRecognizer) {
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

    
}
