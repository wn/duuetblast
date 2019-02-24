// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A level class used to wrap a level in the game. Stores information
 relating to a particular level.
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import Foundation
import CoreData

public class Level {
    var gridBubbles: [GridBubble] = []
    var emptyType: BubbleType
    let rows: Int
    let cols: Int

    public init(rows: Int, col: Int, fillType: BubbleType) {
        self.rows = rows
        self.cols = col
        var index = 0
        emptyType = fillType
        // Generate bubbles based on
        for row in 0..<rows {
            // There should be one less bubble in odd rows to create the required pattern from
            // https://cs3217.gitbooks.io/problem-sets/content/ps/PS3/PS3.html#create-the-bubble-palette
            let numOfColumnsToGenerate = row % 2 == 0 ? col : col - 1
            for _ in 0..<numOfColumnsToGenerate {
                let newBubble = GridBubble(bubbleType: fillType, index: index)
                gridBubbles.append(newBubble)
                index += 1
            }
        }
    }

    public var count: Int {
        return gridBubbles.count
    }

    /// Return the game bubble at the index provided.
    public func getBubbleTypeAtIndex(index: Int) -> BubbleType {
        return gridBubbles[index].bubbleType
    }

    /// Set the game bubble at the index provided to the bubbleType input.
    public func setBubbleTypeAtIndex(index: Int, bubbleType: BubbleType) {
        gridBubbles[index].bubbleType = bubbleType
    }

    /// Set the game bubble at the index provided to the bubbleType input.
    /// Used to init bubble from database.
    public func setBubbleTypeAtIndex(index: Int, bubbleTypeIndex: Int) {
        gridBubbles[index].bubbleType = BubbleType.getBubbleType(bubbleTypeIndex: bubbleTypeIndex)
    }

    /// Set bubble to next color in cycle, used for singleTapForGameBubble gesture.
    public func cycleTypeAtIndex(index: Int) {
        gridBubbles[index].cycleNextColor()
    }

    /// Set all gridBubbles to empty.
    public func eraseAllBubbles() {
        gridBubbles.forEach { $0.bubbleType = emptyType }
    }

    public func setAllBubbleAsType(type: BubbleType) {
        gridBubbles.forEach { $0.bubbleType = type }
    }

    /// Save level to database.
    public func saveGridBubblesToDatabase(name: String) {
        let levelData = LevelData(name: name)
        levelData.saveBubbles(bubbles: gridBubbles)
    }

    var isEmpty: Bool {
        for bubble in gridBubbles where bubble.bubbleType != emptyType {
            return false
        }
        return true
    }
}
