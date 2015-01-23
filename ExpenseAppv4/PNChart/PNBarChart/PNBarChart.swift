//
//  PNBarChart.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/6/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit
import QuartzCore

public class PNBarChart: UIView {
    
    // MARK: Variables
    
    var chartData: (List: [[[Expense]]], labels: [String], tags: [Tag]) = ([[[Expense]]](), [String](), [Tag]())
    var selectedBarData: Int = 0
    var chartCavanHeight = CGFloat(0)
    var viewType = 0
    var listOfLabels = [UILabel]()
    var listOfBars = [PNBar]()
    
    public  var xLabels: NSArray = [] {
        
        didSet{
            if showLabel {
                xLabelWidth = (self.frame.size.width) / CGFloat(self.xLabels.count)
                //xLabelWidth = (self.frame.size.width - chartMargin * 2.0) / CGFloat(self.xLabels.count)
            }
        }
    }
    var labels: NSMutableArray = []
    var yLabels: NSArray = []
    public var yValues: [[Double]] = [] {
        didSet{
            if (yMaxValue != nil) {
                yValueMax = yMaxValue
                //I can set a maximum y Value or iterate to find the maximum
            }else{
                //self.getYValueMax(yValues)
            }
            
            xLabelWidth = (self.frame.size.width) / CGFloat(yValues.count)
            //xLabelWidth = (self.frame.size.width - chartMargin * 2.0) / CGFloat(yValues.count)
        }
    }
    
    var bars: NSMutableArray = []
    public var xLabelWidth:CGFloat!
    public var yValueMax = CGFloat()
    public var strokeColor: UIColor = PNGreenColor
    public var strokeColors: [UIColor] = []
    public var xLabelHeight:CGFloat = 11.0
    public var yLabelHeight:CGFloat = 20.0
    
    /*
    chartMargin changes chart margin
    */
    public var yChartLabelWidth:CGFloat = 18.0
    
    /*
    yLabelFormatter will format the ylabel text
    */
    var yLabelFormatter = ({(index: CGFloat) -> NSString in
        return ""
    })
    
    /*
    chartMargin changes chart margin
    */
    public var chartMargin:CGFloat = 15.0
    
    /*
    showLabel if the Labels should be deplay
    */
    
    public var showLabel = true
    
    /*
    showChartBorder if the chart border Line should be deplay
    */
    
    public var showChartBorder = false
    
    /*
    chartBottomLine the Line at the chart bottom
    */
    
    public var chartBottomLine:CAShapeLayer = CAShapeLayer()
    
    /*
    chartLeftLine the Line at the chart left
    */
    
    public var chartLeftLine:CAShapeLayer = CAShapeLayer()
    
    /*
    barRadius changes the bar corner radius
    */
    public var barRadius:CGFloat = 0.0
    
    /*
    barWidth changes the width of the bar
    */
    public var barWidth:CGFloat!
    
    /*
    labelMarginTop changes the width of the bar
    */
    public var labelMarginTop: CGFloat = 0
    
    /*
    barBackgroundColor changes the bar background color
    */
    public var barBackgroundColor:UIColor = UIColor.grayColor()
    
    /*
    labelTextColor changes the bar label text color
    */
    public var labelTextColor: UIColor = PNGreyColor
    
    /*
    labelFont changes the bar label font
    */
    public var labelFont: UIFont = UIFont.systemFontOfSize(11.0)
    
    /*
    xLabelSkip define the label skip number
    */
    public var xLabelSkip:Int = 1
    
    /*
    yLabelSum define the label skip number
    */
    public var yLabelSum:Int = 4
    
    /*
    yMaxValue define the max value of the chart
    */
    public var yMaxValue:CGFloat!
    
    /*
    yMinValue define the min value of the chart
    */
    public var yMinValue:CGFloat!
    
    var delegate:PNChartDelegate!
    
    var listOfExpenses: [[[Expense]]] = []
    
    /**
    * This method will call and stroke the line in animation
    */
    
    // MARK: Functions
    
    
    func summedExpenseByTags() -> [[Double]] {
        var listToReturn: [[Double]] = []
        
        for i in 0..<listOfExpenses.count {
            var tempArray = [Double]()
            
            for j in 0..<listOfExpenses[i].count {
                
                var count = 0.0
                
                for k in 0..<listOfExpenses[i][j].count {
                    count += listOfExpenses[i][j][k].amount.doubleValue
                }
                

                
                tempArray.append(count)
            }
            
            listToReturn.append(tempArray)


        }
        
        /*
        for i in 0..<listToReturn.count {
            
            println("Day is \(i)")
            for j in 0..<listToReturn[i].count {
                println("\(j) the expense is \(listToReturn[i][j])")
            }
            
        }*/

        
        return listToReturn
    }
    
    public func strokeChart() {
        self.viewCleanupForCollection(labels)
        
        if showLabel{
            //Add x labels
            var labelAddCount:Int = 0
            for var index:Int = 0; index < xLabels.count; ++index {
                labelAddCount += 1
                
                if labelAddCount == xLabelSkip {
                    var labelText:NSString = xLabels[index] as NSString
                    var label:PNChartLabel = PNChartLabel(frame: CGRectZero)
                    label.font = labelFont
                    label.textColor = labelTextColor
                    label.textAlignment = NSTextAlignment.Center
                    label.text = labelText
                    label.font = UIFont.boldSystemFontOfSize(12)
                    label.sizeToFit()
                    label.font = labelFont
                    var labelXPosition:CGFloat  = ( CGFloat(index) *  xLabelWidth + xLabelWidth / 2.0)
                    //var labelXPosition:CGFloat  = ( CGFloat(index) *  xLabelWidth + xLabelWidth / 2.0 + chartMargin)
                    
                    label.center = CGPointMake(labelXPosition, self.frame.size.height - xLabelHeight - chartMargin + label.frame.size.height / 2.0 + labelMarginTop)

                    labelAddCount = 0
                    
                    labels.addObject(label)
                    listOfLabels.append(label)
                    self.addSubview(label)
                }
            }
            
        }
        
        self.viewCleanupForCollection(bars)
        //Add bars
        chartCavanHeight = frame.size.height  - chartMargin * 2 - xLabelHeight
        var index:Int = 0
        
        yValues = summedExpenseByTags()
        
        for intArray in yValues {
            
            var grade: [CGFloat] = []
            var totalValueForTag = 0.0
            var overMaxValue = false
            var overLimitValue = false
            
            for i in 0..<intArray.count {
                
                totalValueForTag += intArray[i]
            }
            
            if CGFloat(totalValueForTag) > yValueMax {
                for i in 0..<intArray.count {
                    grade.append(CGFloat(intArray[i] / totalValueForTag ))//percentage value
                }
                overMaxValue = true
            } else {
                for i in 0..<intArray.count {
                    grade.append(CGFloat(intArray[i]) / yValueMax )//percentage value
                }
                
                if totalValueForTag > Double((yValueMax / 4) * 3) {
                    overLimitValue = true
                }
            }
            
            var bar:PNBar!
            var barXPosition:CGFloat!
            
            if barWidth > 0 { //maintains spacing along each bar
                barXPosition = CGFloat(index) *  xLabelWidth + (xLabelWidth / 2.0) - (barWidth / 2.0)
                //barXPosition = CGFloat(index) *  xLabelWidth + chartMargin + (xLabelWidth / 2.0) - (barWidth / 2.0)
            }else{ //sets the beginning bar inset from edge
                barXPosition = CGFloat(index) *  xLabelWidth + xLabelWidth * 0.05
                //barXPosition = CGFloat(index) *  xLabelWidth + chartMargin + xLabelWidth * 0.05
                if showLabel {
                    barWidth = xLabelWidth * 0.9 //Changes the width of the bar (BUT must change else {barXPosition})
                    
                }
                else {
                    barWidth = xLabelWidth * 0.6
                    
                }
            }
            
            bar = PNBar(frame: CGRectMake(barXPosition, //Bar X position
                frame.size.height - chartCavanHeight - xLabelHeight - chartMargin, //Bar Y position
                barWidth, // Bar witdh
                chartCavanHeight), colors: strokeColors) //Bar height
            
            //Change Bar Radius
            bar.barRadius = barRadius
            
            //Change Bar Background color + bar color passed to PNBar
            bar.backgroundColor = barBackgroundColor
            
            //Height Of Bar
            for i in 0..<intArray.count {
                bar.grade.append(grade[i])
            }
            
            if (overMaxValue) {
                //////////////Style choices////////////////
                
                //bar.alpha = 0.4
                listOfLabels[index].textColor = UIColor.redColor()
                
                ///////////////////////////////////////////
                
                //create white diagonal line
                UIGraphicsBeginImageContextWithOptions(bar.frame.size, false, 0)
                
                //Get current image context
                let context = UIGraphicsGetCurrentContext()
                
                // Perform the drawing
                CGContextSetLineWidth(context, 3)
                CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
                
                CGContextMoveToPoint(context, -5, bar.frame.size.height/2 + 15 + 5)
                CGContextAddLineToPoint(context, bar.frame.size.width + 5, bar.frame.size.height/2 - 15 + 5)
                
                CGContextMoveToPoint(context, -5, bar.frame.size.height/2 + 15 - 5)
                CGContextAddLineToPoint(context, bar.frame.size.width + 5, bar.frame.size.height/2 - 15 - 5)
                
                CGContextStrokePath(context)
                
                // Retrieve the drawn image
                let imageView = UIImageView(frame: CGRectMake(0, 0, bar.frame.size.width, bar.frame.size.height))
                imageView.image = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                
                bar.addSubview(imageView)
                
            }
            
            if overLimitValue {
                listOfLabels[index].textColor = UIColor.redColor()
            }
            
            //For Click Index
            bar.tag = index  + 1
            
            bars.addObject(bar)
            addSubview(bar)
            
            listOfBars.append(bar)

            index += 1
            
        }
        
    }

    func sumOfIntArray(intArray: [Int]) -> Int {
        var tally = 0
        for i in intArray {
            tally += i
        }
        return tally
    }
    
    
    func viewCleanupForCollection( array:NSMutableArray )
    {
        if array.count > 0 {
            for object:AnyObject in array{
                var view = object as UIView
                view.removeFromSuperview()
            }
            
            array.removeAllObjects()
        }
    }
    
    func getYValueMax(yLabels:[[Int]]) {
        
        var max = 0
        
        
        for i in yLabels {
            if sumOfIntArray(i) > max {
                max = sumOfIntArray(i)
            }
        }
        
        if max == 0 {
            yValueMax = yMinValue
        }else{
            //yValueMax = CGFloat(max) &&&*&*^)(*&)(*%(* MADE A CHANGE HERE TO yVALUE MAX!!!!!!
        }
        
    }
    
    public func touchPoint(location: CGPoint) {
        
        if let subview = hitTest(location, withEvent: nil) {
            
            if subview.tag != 0 {
                selectBar(listOfBars.count - (subview.tag))
            }
        }
        
    }
    
    var prevBarSelect: PNBar = PNBar(frame: CGRectMake(0, 0, 0, 0), colors: [])
    var prevLabelSelect = UILabel()
    
    func selectBar(j: Int) {
        
        let i = listOfBars.count - j - 1
        
        let selectedBar: PNBar = listOfBars[i]
        
        self.delegate?.userClickedOnBar(listOfExpenses[i])
        
        if selectedBar == prevBarSelect {
            return
        }
        
        UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: nil, animations: {
            
            selectedBar.transform = CGAffineTransformMakeScale(1.05, 1.05)
            self.prevBarSelect.transform = CGAffineTransformMakeScale(1, 1)
            
            self.listOfLabels[i].frame.origin = CGPointMake(self.listOfLabels[i].frame.origin.x, self.listOfLabels[i].frame.origin.y + 4.5)
            self.prevLabelSelect.frame.origin = CGPointMake(self.prevLabelSelect.frame.origin.x, self.prevLabelSelect.frame.origin.y - 4.5)
            
            if self.listOfLabels[i].textColor != UIColor.redColor() {
                self.listOfLabels[i].textColor = UIColor.blackColor()
            }
            self.listOfLabels[i].font = UIFont.boldSystemFontOfSize(11)
            self.prevLabelSelect.font = UIFont.systemFontOfSize(11)
            
            if self.prevLabelSelect.textColor != UIColor.redColor() {
                self.prevLabelSelect.textColor = self.labelTextColor
                
            }
            
            
            }, completion: {(bool) in
                
                self.prevBarSelect = selectedBar
                self.prevLabelSelect = self.listOfLabels[i]
        })
    }
    
    
    
    // MARK: Init
    
    override public init(frame: CGRect)
    {
        super.init(frame: frame)
        barBackgroundColor = PNLightGreyColor
        clipsToBounds = true
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
