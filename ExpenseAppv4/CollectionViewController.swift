//
//  CollectionViewController.swift
//  test3
//
//  Created by Francis Young on 12/02/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController {
    
    var listOfLabels = [String]()
    var chartData: (List: [[[Expense]]], labels: [String], tags: [Tag]) = ([[[Expense]]](), [String](), [Tag]())
    var strokeColors: [UIColor] = [UIColor]()

    var yValueMax = CGFloat()
    var yValues = [[Double]]()
    var viewType: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        yValues = summedExpenseByTags()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView?.selectItemAtIndexPath(NSIndexPath(forItem: listOfExpenses.count - 1, inSection: 0), animated: false, scrollPosition: .Right)
        //collectionView?.contentOffset = CGPoint(x: self.collectionView?.frame.size.x - 320, 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return listOfExpenses.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: CollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as CollectionViewCell
        
        let intArray = yValues[indexPath.item]
        
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
        
        cell.overMaxValue = overMaxValue
        cell.overLimitValue = overLimitValue
        
        cell.barColor = strokeColors
        
        for i in 0..<intArray.count {
            cell.grade.append(grade[i])
        }
        
        cell.dateLabel.text = listOfLabels[indexPath.item]
        
        // Configure the cell
    
        return cell
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    var listOfExpenses: [[[Expense]]] = []
    
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
        return listToReturn
    }

}
