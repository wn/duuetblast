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
    var isRect: Bool
    var levelName: String?
    var time: Int = Constants.defaultTime
    var highscore = 0
    var screenshot: Data?

    public init(totalBubbles: Int, fillType: BubbleType, isRect: Bool) {
        self.isRect = isRect
        emptyType = fillType
        // Generate bubbles based on
        for index in 0..<totalBubbles {
            let newBubble = GridBubble(bubbleType: fillType, index: index)
            gridBubbles.append(newBubble)
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

    public func saveHighScore(score: Int) -> Bool {
        guard let levelName = levelName, let screenshot = screenshot else {
            return false
        }
        guard score > 0, score > highscore else {
            return false
        }
        highscore = score
        saveGridBubblesToDatabase(name: levelName, isRectGrid: isRect, time: time, screenshot: screenshot)
        return true
    }

    /// Save level to database.
    public func saveGridBubblesToDatabase(name: String, isRectGrid: Bool, time: Int, screenshot: Data) {
        // If level exist, we delete it.
        _ = LevelData.deleteLevel(name: name)

        let levelData = LevelData(name: name, isRect: isRectGrid, time: Int16(time), highscore: Int32(highscore), screenshot: screenshot)
        levelName = name
        self.time = time
        self.screenshot = screenshot
        levelData.saveBubbles(bubbles: gridBubbles)
    }

    var isEmpty: Bool {
        for bubble in gridBubbles where bubble.bubbleType != emptyType {
            return false
        }
        return true
    }
}
