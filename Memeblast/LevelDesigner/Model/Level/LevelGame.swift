//
//  LevelGame.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 11/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import Foundation

public class LevelGame: Level {
    public override init(totalBubbles: Int, fillType: BubbleType, isRect: Bool) {
        super.init(totalBubbles: totalBubbles, fillType: fillType, isRect: isRect)
    }

    func isEmptyAtIndex(index: Int) -> Bool {
        return gridBubbles[index].bubbleType == emptyType
    }

    func setEmptyCells(type: BubbleType) {
        gridBubbles.filter {$0.bubbleType == emptyType}.forEach {$0.bubbleType = type}
    }

    func clone() -> LevelGame {
        let newLevel = LevelGame(totalBubbles: gridBubbles.count, fillType: emptyType, isRect: isRect)
        for index in 0..<gridBubbles.count {
            let bubbleType = getBubbleTypeAtIndex(index: index)
            newLevel.setBubbleTypeAtIndex(index: index, bubbleType: bubbleType)
        }
        return newLevel
    }
}
