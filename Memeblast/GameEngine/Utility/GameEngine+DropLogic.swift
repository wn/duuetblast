//
//  GameEngine+DropLogic.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 18/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import CoreGraphics

extension GameEngine {

    public func dropBubbleDueToCollision(bubble: GameBubble, collidedBubble: GameBubble) -> CGPoint? {
        guard let collidedBubbleIndex = collidedBubble.index else {
            fatalError("Collied bubble must be in game, hence must have an index.")
        }
        let topLeftPoint = bubble.getRenderingPosition // We use top-left as grid references are all using top-left
        guard let delegate = gameDelegate else {
            return nil
        }
        guard
            let minNeighbourIndex = getNearestEmptyNeighbourIndex(
                topLeftPoint: topLeftPoint,
                collidedBubbleIndex: collidedBubbleIndex) else {
                    setFreefallBubble(bubble)
                    return nil
        }
        bubble.index = minNeighbourIndex
        return delegate.setBubbleTypeAndGetPosition(
            bubbleType: bubble.bubbleType,
            indexPath: delegate.getIndexPathAtIndex(index: minNeighbourIndex))
    }

    public func getNearestEmptyNeighbourIndex(topLeftPoint: CGPoint, collidedBubbleIndex: Int) -> Int? {
        let neighboursIndex = getEmptyNeighbouringIndex(collidedBubbleIndex)
        guard
            let delegate = gameDelegate,
            var minNeighbourIndex = neighboursIndex.first else {
            return nil
        }
        var minDistance = CGFloat.greatestFiniteMagnitude
        for neighbourIndex in neighboursIndex {
            guard let neighbourPosition = delegate.getPositionAtIndex(index: neighbourIndex) else {
                continue
            }
            let distance = topLeftPoint.displacementTo(point: neighbourPosition)
            if distance < minDistance {
                minDistance = distance
                minNeighbourIndex = neighbourIndex
            }
        }
        return minNeighbourIndex
    }

    public func getNeighbouringIndex(_ index: Int) -> [Int] {
        let result = gameLayout.getNeighboursAtIndex(index)
        return result.filter { $0 >= 0 && $0 < gameLayout.totalNumberOfBubble }
    }

    public func getNonEmptyNeighbouringIndex(_ index: Int) -> [Int] {
        guard let delegate = gameDelegate else {
            return []
        }
        return getNeighbouringIndex(index).filter {
            !delegate.currentLevel.isEmptyAtIndex(index: $0)
        }
    }

    public func getEmptyNeighbouringIndex(_ index: Int) -> [Int] {
        guard let delegate = gameDelegate else {
            return []
        }
        return getNeighbouringIndex(index).filter {
            delegate.currentLevel.isEmptyAtIndex(index: $0)
        }
    }
}
