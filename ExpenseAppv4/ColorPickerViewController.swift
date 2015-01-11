//
//  ColorPickerViewController.swift
//  ExpenseAppv4
//
//  Created by Francis Young on 31/12/2014.
//  Copyright (c) 2014 Francis Young. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var colorPickerView: HRColorPickerView!
    @IBOutlet weak var tagLabel:UITextField!
    
    var colorPassed = UIColor()
    var textPassed = ""
    var index: NSIndexPath = NSIndexPath()
    
    var delegate: ColorPickerDelegate! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.colorPickerView.color = colorPassed
        self.tagLabel.placeholder = textPassed
        
        self.tagLabel.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        var textReturned = ""
        
        if tagLabel.text == "" {
            textReturned = textPassed
        } else {
            textReturned = tagLabel.text
        }
        
        delegate.updateTags(self, tag: textReturned, color: colorPickerView.color, index: index)
        super.viewWillDisappear(animated)
    }
    
    //Dismiss keyboard when touch 'Done' button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.tagLabel {
            textField.resignFirstResponder()
        }
        return true
    }
    
    //changes color of UITextField when selected
    func textFieldDidBeginEditing(textField: UITextField) {
        
        textField.textColor = appColor.selectedTintColor
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (countElements(textField.text) + countElements(string)) > 25 {
            errorShakeView(textField) //CHARACTER LIMIT OF 30
            return false
        } else {
            return true
        }

    }
}

protocol ColorPickerDelegate {
    func updateTags(controller: ColorPickerViewController, tag: String, color: UIColor, index: NSIndexPath)

    
}
