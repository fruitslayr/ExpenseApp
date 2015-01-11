//
//  Expense.swift
//  ExpenseAppv4
//
//  Created by Francis Young on 6/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import Foundation
import CoreData

class Expense: NSManagedObject {

    @NSManaged var amount: NSNumber!
    @NSManaged var dateAndTime: NSDate!
    @NSManaged var name: String?
    @NSManaged var coordinate: Coordinate?
    @NSManaged var tag: Tag!

}
