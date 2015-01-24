//
//  UIPageVC.swift
//  ExpenseTrackr
//
//  Created by Francis Young on 21/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import UIKit

class UIPageVC: UIViewController {

    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var pageControl:UIPageControl!
    
    var index: Int = 0
    var heading: String = ""
    var imageFile: String = ""
    var descriptionText: String = ""
    //var button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentImageView.image = UIImage(named: imageFile)
        pageControl.currentPage = index
        getStartedButton.layer.borderColor = appColor.orangeColor.CGColor
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.boolForKey("hasViewedWalkthrough"){
            getStartedButton.setTitle("Close", forState: .Normal)
        } else {
            getStartedButton.setTitle("Get Started!", forState: .Normal)
        }
        
        
        var shimmeringView = FBShimmeringView(frame: getStartedButton.frame)
        self.view.addSubview(shimmeringView)
        shimmeringView.contentView = getStartedButton
        shimmeringView.shimmeringPauseDuration = 2
        shimmeringView.shimmeringSpeed = 130
        shimmeringView.shimmeringAnimationOpacity = 0.5

        shimmeringView.shimmering = true
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "hasViewedWalkthrough")
    }

}
