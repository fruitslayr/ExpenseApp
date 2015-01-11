//
//  Coordinate.swift
//  ExpenseAppv4
//
//  Created by Francis Young on 6/01/2015.
//  Copyright (c) 2015 Francis Young. All rights reserved.
//

import Foundation
import CoreData

class Coordinate: NSManagedObject {

    @NSManaged var latitude: NSNumber!
    @NSManaged var longitude: NSNumber!
    @NSManaged var expense: Expense

}
