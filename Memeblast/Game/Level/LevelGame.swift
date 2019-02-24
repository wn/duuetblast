//
//  LevelGame.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 11/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import Foundation

public class LevelGame: Level {
    public override init(rows: Int, col: Int, fillType: BubbleType) {
        super.init(rows: rows, col: col, fillType: fillType)
    }

    func isEmptyAtIndex(index: Int) -> Bool {
        return gridBubbles[index].bubbleType == emptyType
    }

    func setEmptyCells(type: BubbleType) {
        gridBubbles.filter {$0.bubbleType == emptyType}.forEach {$0.bubbleType = type}
    }

    func clone() -> LevelGame {
        let newLevel = LevelGame(rows: rows, col: cols, fillType: emptyType)
        for index in 0..<gridBubbles.count {
            let bubbleType = getBubbleTypeAtIndex(index: index)
            newLevel.setBubbleTypeAtIndex(index: index, bubbleType: bubbleType)
        }
        return newLevel
    }
}
