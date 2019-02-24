//
//  RectLayout.swift
//  Memeblast
//
//  Created by Ang Wei Neng on 24/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import Foundation

struct RectLayout: GameLayout {
    let numberOfRows: Int
    let numberOfColInRow: Int

    init(rows: Int, firstRowCol: Int, secondRowCol: Int) {
        numberOfRows = rows
        numberOfColInRow = firstRowCol
    }

    var totalNumberOfBubble: Int {
        return numberOfColInRow * numberOfRows
    }

    func getNeighboursAtIndex(_ index: Int) -> [Int] {
        var neighbour = [index - 1, index + 1, index - numberOfColInRow, index + numberOfColInRow]
        if index % numberOfColInRow == 0 {
            // First element of the row should not have left neighbour
            neighbour = [index + 1, index - numberOfColInRow, index + numberOfColInRow]
        } else if index % numberOfColInRow == numberOfColInRow - 1 {
            // Last element of the row should not have right neighbour
            neighbour = [index - 1, index - numberOfColInRow, index + numberOfColInRow]
        }
        return neighbour.filter { $0 >= 0 && $0 < totalNumberOfBubble }
    }

    public func getRowIndexes(_ index: Int) -> [Int] {
        guard index >= 0 && index < totalNumberOfBubble else {
            return []
        }
        var currIndex = 0
        for _ in 0..<numberOfRows {
            if index >= currIndex && index < currIndex + numberOfColInRow {
                return Array(currIndex..<(currIndex + numberOfColInRow))
            }
            currIndex += numberOfColInRow
        }
        return []
    }
}
