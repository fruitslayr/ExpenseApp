//
//  customTableViewCell.swift
//  ExpenseAppv4
//
//  Created by Francis Young on 30/12/2014.
//  Copyright (c) 2014 Francis Young. All rights reserved.
//

import UIKit

class customTableViewCell: UITableViewCell {

    @IBOutlet weak var tagLabel:UILabel!
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
