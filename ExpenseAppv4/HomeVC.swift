//
//  HomeVC.swift
//  ExpenseAppTestv4
//
//  Created by Francis Young on 27/12/2014.
//  Copyright (c) 2014 Francis Young. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, PNChartDelegate {

    @IBOutlet weak var barGraph: UIView!
    @IBOutlet weak var barScrollView: UIScrollView!
    
    @IBOutlet weak var detailScrollView: UIScrollView!
    @IBOutlet weak var detailBar: UIView!
    @IBOutlet weak var detailHeading: UIView!
    
    var barChart = PNBarChart(frame: CGRectMake(0, 0, 640, 354))
    var coreDataStack: CoreDataStack!
    var chartDataController: ChartDataController!
    
    var expenseListForSegue: [[Expense]]!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let singleTap = UITapGestureRecognizer(target: self, action: "handleTap:")
        let pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        barScrollView.addGestureRecognizer(singleTap)
        barScrollView.addGestureRecognizer(pinch)
        self.automaticallyAdjustsScrollViewInsets = false
        
        chartDataController = ChartDataController(coreDataStack: coreDataStack)
        let data = chartDataController.daily()
        updateDetailBar(data.dailyList[0])
        
        let singleTap2 = UITapGestureRecognizer(target: self, action: "handleTap2:")
        detailScrollView.addGestureRecognizer(singleTap2)
        
    }

    override func viewWillAppear(animated: Bool) {
        createBarGraph()
        barScrollView.addSubview(barGraph)
        
        let data = chartDataController.daily()
        updateDetailBar(data.dailyList[0])

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(segue:UIStoryboardSegue) {}

    func createBarGraph() {
        
        barChart.backgroundColor = UIColor.clearColor()
        barChart.labelMarginTop = 5.0
        
        //create chartdatacontroller
        let data = chartDataController.daily()
        
        //Set up size of views and controllers
        barChart.frame = CGRectMake(0, 0, 46 * CGFloat(data.labels.count), 354)
        barScrollView.contentSize = CGSizeMake(46 * CGFloat(data.labels.count), 354)
        barScrollView.clipsToBounds = true
        barScrollView.contentOffset = CGPointMake(46 * CGFloat(data.labels.count)-320, 0) //Results in the offset to to allow scrolling from right to left

        
        //change size according to requirements

        barChart.xLabels = data.labels.reverse()
        barChart.listOfExpenses = data.dailyList.reverse()
        
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

    
}
