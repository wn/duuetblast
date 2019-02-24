//
//  GameLayout.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 19/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

struct GameLayout {
    let numberOfRows: Int
    let numberOfColInFirstRow: Int
    let numberOfColInSecondRow: Int

    init(rows: Int, firstRowCol: Int, secondRowCol: Int) {
        numberOfRows = rows
        numberOfColInFirstRow = firstRowCol
        numberOfColInSecondRow = secondRowCol
    }

    var totalNumberOfBubble: Int {
        var result = 0
        for row in 0..<numberOfRows {
            result += row % 2 == 0 ? numberOfColInFirstRow : numberOfColInSecondRow
        }
        return result
    }

    func getNeighboursAtIndex(_ index: Int) -> [Int] {
        let numOfBubblesInFirstRow = numberOfColInFirstRow
        let numOfBubblesInSecondRow = numberOfColInSecondRow
        let totalPerTwoRows = numOfBubblesInFirstRow + numOfBubblesInSecondRow
        var result = [index - numOfBubblesInFirstRow + 1,
                      index - numOfBubblesInFirstRow,
                      index - 1,
                      index + 1,
                      index + numOfBubblesInFirstRow - 1,
                      index + numOfBubblesInFirstRow]

        switch index % totalPerTwoRows {
        case 0:
            // Start of first row
            result = [index - numOfBubblesInSecondRow, index + 1, index + numOfBubblesInFirstRow]
        case numOfBubblesInSecondRow:
            // End of first row
            result = [index - numOfBubblesInFirstRow, index - 1, index + numOfBubblesInSecondRow]
        case numOfBubblesInFirstRow:
            // Start of second row
            result = result.filter { $0 != index - 1 }
        case totalPerTwoRows - 1:
            // End of second row
            result = result.filter { $0 != index + 1 }
        default: break
        }
        return result
    }

    public func getRowIndexes(_ index: Int) -> [Int] {
        guard index >= 0 && index < totalNumberOfBubble else {
            return []
        }
        let firstRow = 12
        let secondRow = firstRow - 1
        let loop = [firstRow, secondRow]
        var currIndex = 0
        for rowNumber in 0..<numberOfRows {
            let numOfBubblesInRow = loop[rowNumber % 2]
            if index > currIndex && index < currIndex + numOfBubblesInRow {
                return Array(currIndex..<(currIndex + numOfBubblesInRow))
            }
            currIndex += numOfBubblesInRow
        }
        return []
    }
}
