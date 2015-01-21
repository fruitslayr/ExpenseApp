//
//  PageVC.swift
//  ExpenseTrackr
//
//  Created by Francis Young on 21/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import UIKit

class PageVC: UIPageViewController, UIPageViewControllerDataSource {

    var pageImages = ["DemoView1.png", "DemoView2.png", "DemoView3.png"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = self
        
        if let startingViewController = self.viewControllerAtIndex(0) {
            setViewControllers([startingViewController], direction: .Forward, animated: true, completion: nil)
        }
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as UIPageVC).index
        
        index++
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as UIPageVC).index
        
        index--
        
        return self.viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> UIPageVC? {
        if index == NSNotFound || index < 0 || index >= self.pageImages.count {
            return nil
        }
        
        if let pageContentVC = storyboard?.instantiateViewControllerWithIdentifier("UIPageVC") as? UIPageVC {
            
            pageContentVC.imageFile = pageImages[index]
            pageContentVC.index = index
            
            return pageContentVC
        }
        
        return nil
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
