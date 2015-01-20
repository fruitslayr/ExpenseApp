//
//  PNChartDelegate.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/5/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit

protocol PNChartDelegate {
    /**
    * When user click on a chart bar
    *
    */
    func userClickedOnBar(expenseList: [[Expense]])
}