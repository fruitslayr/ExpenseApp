//
//  CollectionViewController.swift
//  test3
//
//  Created by Francis Young on 12/02/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"
let itemCount = 10
var prevBarIndexPath = NSIndexPath(forItem: itemCount - 1, inSection: 0)
var barBeingAnimated = false

class CollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.collectionView?.scrollRectToVisible(CGRectMake(0, 0, 540, 354), animated: false)
        
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
        return itemCount
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        println(indexPath)
        
        let cell: CollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as CollectionViewCell
        
        cell.text.text = "Dec 15"
        
        if indexPath == prevBarIndexPath {
            cell.view.transform = CGAffineTransformMakeScale(1.05, 1.05)
            cell.text.frame.origin = CGPointMake(cell.text.frame.origin.x, cell.text.frame.origin.y + 4.5)
            cell.text.font = UIFont.boldSystemFontOfSize(11)
        }
        
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
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if barBeingAnimated == true {return}
        if indexPath == prevBarIndexPath {return}
        
        barBeingAnimated = true
        
        let selectedBar = self.collectionView?.cellForItemAtIndexPath(indexPath) as CollectionViewCell
        let prevBarSelected = self.collectionView?.cellForItemAtIndexPath(prevBarIndexPath) as CollectionViewCell
        
        UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: nil, animations: {
            
            selectedBar.view.transform = CGAffineTransformMakeScale(1.05, 1.05)
            prevBarSelected.view.transform = CGAffineTransformMakeScale(1, 1)
            
            selectedBar.text.frame.origin = CGPointMake(selectedBar.text.frame.origin.x, selectedBar.text.frame.origin.y + 4.5)
            prevBarSelected.text.frame.origin = CGPointMake(prevBarSelected.text.frame.origin.x, prevBarSelected.text.frame.origin.y - 4.5)
            
//            if self.listOfLabels[i].textColor != UIColor.redColor() {
//                self.listOfLabels[i].textColor = UIColor.blackColor()
//            }
            selectedBar.text.font = UIFont.boldSystemFontOfSize(11)
            prevBarSelected.text.font = UIFont.systemFontOfSize(11)
            
//            if self.prevLabelSelect.textColor != UIColor.redColor() {
//                self.prevLabelSelect.textColor = self.labelTextColor
//                
//            }
            
            }, completion: {(bool) in
                prevBarIndexPath = indexPath
                barBeingAnimated = false
        })
        
        
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

}
