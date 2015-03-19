//
//  customExpenseTableViewCell.swift
//  ExpenseAppv4
//
//  Created by Francis Young on 11/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import UIKit

class customExpenseTableViewCell: UITableViewCell {

    @IBOutlet weak var expenseLabel:UILabel!
    @IBOutlet weak var expenseName: UILabel!
    @IBOutlet weak var colorView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
