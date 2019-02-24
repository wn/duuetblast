//
//  GameLayout.swift
//  Memeblast
//
//  Created by Ang Wei Neng on 24/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import Foundation

protocol GameLayout {
    var totalNumberOfBubble: Int {get}

    init(rows: Int, firstRowCol: Int, secondRowCol: Int)
    func getNeighboursAtIndex(_ index: Int) -> [Int]
    func getRowIndexes(_ index: Int) -> [Int]
}
