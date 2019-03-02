//
//  LevelGame.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 11/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import Foundation
import CoreData

public class LevelGame: Level {
    public override init(totalBubbles: Int, fillType: BubbleType, isRect: Bool) {
        super.init(totalBubbles: totalBubbles, fillType: fillType, isRect: isRect)
    }

    func isEmptyAtIndex(index: Int) -> Bool {
        return gridBubbles[index].bubbleType == emptyType
    }

    func setEmptyCells(type: BubbleType) {
        gridBubbles.filter {$0.bubbleType == emptyType}.forEach {$0.bubbleType = type}
        emptyType = type
    }

    func clone() -> LevelGame {
        let newLevel = LevelGame(totalBubbles: gridBubbles.count, fillType: emptyType, isRect: isRect)
        for index in 0..<gridBubbles.count {
            let bubbleType = getBubbleTypeAtIndex(index: index)
            newLevel.setBubbleTypeAtIndex(index: index, bubbleType: bubbleType)
        }
        newLevel.levelName = levelName
        newLevel.time = time
        newLevel.highscore = highscore
        newLevel.screenshot = screenshot
        return newLevel
    }

    static func retrieveLevels() -> [LevelData] {
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LevelData")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            return result as! [LevelData]
        } catch {
            return []
        }
    }

    static func retrieveLevel(_ name: String) -> LevelGame? {
        let levels = retrieveLevels()
        for level in levels {
            guard let levelName = level.value(forKey: "levelName") as? String,
                name == levelName,
                let levelBubbles = level.bubbles as? Set<GridBubbleData> else {
                    continue
            }
            guard let isRectGrid = level.value(forKey: "isRectGrid") as? Bool else {
                fatalError("isRectGrid should have been set in core data")
            }
            guard let time = level.value(forKey: "time") as? Int else {
                fatalError("time should have been set in core data")
            }
            guard let highscore = level.value(forKey: "highscore") as? Int else {
                fatalError("time should have been set in core data")
            }
            guard let screenshot = level.value(forKey: "screenshot") as? Data else {
                fatalError("screenshot should have been set in core data")
            }
            let resultLevel = LevelGame(totalBubbles: levelBubbles.count, fillType: .empty, isRect: isRectGrid)
            resultLevel.levelName = name
            resultLevel.time = time
            resultLevel.highscore = highscore
            resultLevel.screenshot = screenshot
            for bubble in levelBubbles {
                guard let index = bubble.value(forKey: "position") as? Int,
                    let bubbleTypeIndex = bubble.value(forKey: "bubbleTypeId") as? Int else {
                        fatalError("Database should not have saved an out of bound index or bubbleType," +
                            "and they should be of type Int!")
                }
                resultLevel.setBubbleTypeAtIndex(index: index, bubbleTypeIndex: bubbleTypeIndex)
            }
            return resultLevel
        }
        return nil
    }
}
