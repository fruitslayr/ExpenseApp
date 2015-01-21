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
    @IBOutlet weak var behindButton: UIButton!
    
    var index: Int = 0
    var heading: String = ""
    var imageFile: String = ""
    var descriptionText: String = ""
    //var button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentImageView.image = UIImage(named: imageFile)
        //progressButton = button
        
        getStartedButton.layer.borderColor = UIColor(red: 252/255, green: 156/255, blue: 111/255, alpha: 1).CGColor
        
        
        var shimmeringView = FBShimmeringView(frame: getStartedButton.frame)
        self.view.addSubview(shimmeringView)
        shimmeringView.contentView = getStartedButton
        shimmeringView.shimmeringPauseDuration = 4
        shimmeringView.shimmering = true
        shimmeringView.shimmeringSpeed = 100
        
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
