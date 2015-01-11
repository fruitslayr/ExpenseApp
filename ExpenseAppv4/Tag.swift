//
//  Tag.swift
//  ExpenseAppv4
//
//  Created by Francis Young on 6/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import Foundation
import CoreData

class Tag: NSManagedObject {

    @NSManaged var color: UIColor
    @NSManaged var position: NSNumber
    @NSManaged var text: String
    @NSManaged var expense: NSSet

}
