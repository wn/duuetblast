//
//  GameEngine+CollisionLogic.swift
//  Duuetblast
//
//  Created by Ang Wei Neng on 3/3/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit
import WNPhysicsEngine

extension GameEngine {
    // MARK: - Collision Logics
    private func collisionLogic(bubbleOne: GameBubble, bubbleTwo: GameBubble) {
        let finalVelocities = physicsEngine.velocityAfterCollisionTwoDimension(
            velocityOne: bubbleOne.velocity,
            positionOne: bubbleOne.position,
            velocityTwo: bubbleTwo.velocity,
            positionTwo: bubbleTwo.position)
        bubbleOne.velocity = finalVelocities.0
        bubbleTwo.velocity = finalVelocities.1
    }

    /// Get first bubble where collision did happen.
    public func collidedBubble(_ bubble: GameBubble) -> GameBubble? {
        return allCollidedBubbles(bubble).first
    }

    public func allCollidedBubbles(_ bubble: GameBubble) -> [GameBubble] {
        return gameBubbles.filter {
            bubble.isFalling == false
                && didCollideBubbles(bubbleOne: bubble, bubbleTwo: $0)
                && bubble.lastCollidedBubble != $0
        }
    }

    private func didCollideBubbles(bubbleOne: GameBubble, bubbleTwo: GameBubble) -> Bool {
        guard bubbleOne !== bubbleTwo else {
            return false
        }
        return bubbleOne
            .getCenterOfBubble
            .displacementTo(point: bubbleTwo.getCenterOfBubble) <= bubbleOne.diameter
    }

    func collisionWithBubble(bubble: GameBubble) {
        if let collidedBubble = collidedBubble(bubble) {
            bubble.lastCollidedBubble = nil
            switch collidedBubble.movementType {
            case .falling:
                break
            case .stationary:
                guard bubble.bubbleType != .rocket else {
                    // We do not check for collision and let rocket derender itself
                    // when it is out of the game.
                    for hitBubble in allCollidedBubbles(bubble) {
                        activatePower(collidedBubble: hitBubble, collidee: bubble)
                        deregisterBubble(bubble: hitBubble, type: .instant)
                        gameDelegate?.score += Constants.rocketPoints
                    }
                    dropNonAttachedBubbles()
                    return
                }
                dropFiringBubble(bubble: bubble, collidedBubble: collidedBubble)

                activatePower(collidedBubble: collidedBubble, collidee: bubble)
                return
            case .moving:
                // Guard against multiple collision with the same object
                guard bubble.lastCollidedBubble != collidedBubble else {
                    break
                }
                guard bubble.bubbleType != .chainsawBubble && collidedBubble.bubbleType != .chainsawBubble else {
                    Settings.playSoundWith(Constants.chainsawSound)
                    gameoverAction()
                    return
                }
                bubble.lastCollidedBubble = collidedBubble
                collidedBubble.lastCollidedBubble = bubble

                collisionLogic(bubbleOne: bubble, bubbleTwo: collidedBubble)
            case .inCannon:
                return
            }
        }
        obstacleCollisionAction(bubble)
    }

    // MARK: - Clearing of bubbles logic
    private func destroyBubble(bubble: GameBubble, destroyType: DestroyType) {
        switch destroyType {
        case .matchThree:
            matchThree(bubble: bubble)
        }
        dropNonAttachedBubbles()
    }

    private func matchThree(bubble: GameBubble) {
        guard let index = bubble.index else {
            return
        }
        var toDestroy: [GameBubble] = [bubble]
        var visitedIndexes: [Int] = [index]

        var stack = getNonEmptyNeighbouringIndex(index)
        while let neighbourIndex = stack.popLast() {
            guard !visitedIndexes.contains(neighbourIndex),
                let connectedBubble = gameplayBubbles[neighbourIndex] else {
                    continue
            }
            visitedIndexes.append(neighbourIndex)
            if connectedBubble.bubbleType == bubble.bubbleType {
                toDestroy.append(connectedBubble)
                stack.append(contentsOf: getNonEmptyNeighbouringIndex(neighbourIndex))
            }
        }

        guard toDestroy.count >= 3 else {
            return
        }
        gameDelegate?.score += toDestroy.count * Constants.matchBubblePoints
        toDestroy.forEach { deregisterBubble(bubble: $0, type: .match) }
    }

    // Only game engine can deregister bubble from game
    func deregisterBubble(bubble: GameBubble, type: RemovingBubbleType) {
        switch type {
        case .falling:
            setFreefallBubble(bubble)
            removeBubbleFromGrid(bubble, animation: false)
        case .match:
            gameBubbles.remove(bubble)
            removeBubbleFromGrid(bubble, animation: true)
        case .instant:
            removeBubbleFromGrid(bubble, animation: false)
        }
    }

    /// Set bubble to be in free fall.
    func setFreefallBubble(_ bubble: GameBubble) {
        bubble.velocity.stop()

        // Gravity
        bubble.acceleration = Acceleration.gravity
        bubble.isFalling = true
        renderEngine.renderFallingBubble(bubble: bubble, topLeftPosition: bubble.position)
        movingFiringBubble(bubble)
    }

    private func removeBubbleFromGrid(_ bubble: GameBubble, animation: Bool) {
        guard let delegate = gameDelegate, let index = bubble.index else {
            return
        }
        gameplayBubbles[index] = nil
        delegate.currentLevel.setBubbleTypeAtIndex(index: index, bubbleType: .invisible)
        if animation {
            delegate.reload(index: index)
        } else {
            UIView.performWithoutAnimation {
                delegate.reload(index: index)
            }
        }
    }

    func isAttachedBubbles() -> Set<GameBubble> {
        var visitedIndexes: [Int] = []
        var connectedBubbles: [GameBubble] = []
        var stack = getStableBubbleIndex()
        while let neighbourIndex = stack.popLast() {
            guard !visitedIndexes.contains(neighbourIndex),
                let bubble = gameplayBubbles[neighbourIndex] else {
                    continue
            }
            visitedIndexes.append(neighbourIndex)
            stack.append(contentsOf: getNonEmptyNeighbouringIndex(neighbourIndex))
            connectedBubbles.append(bubble)
        }
        return Set(connectedBubbles)
    }

    func isStableBubble(_ bubble: GameBubble) -> Bool {
        return obstacles.contains { $0.stable && $0.didCollide(bubble: bubble) }
    }

    func dropNonAttachedBubbles() {
        let attachedBubbles = isAttachedBubbles()
        let nonAttachedBubbles = gameBubbles.filter { !attachedBubbles.contains($0) && $0.movementType == .stationary }
        nonAttachedBubbles.forEach { deregisterBubble(bubble: $0, type: .falling) }
        gameDelegate?.score += nonAttachedBubbles.count * Constants.unattachedBubblePoints

        // We check if win in this function as before winning,
        // this function must be called.
        activateWinningActionIfWin()
    }

    private func dropBubble(bubble: GameBubble, didCollideBubble: GameBubble?) -> CGPoint? {
        guard let delegate = gameDelegate else {
            return nil
        }
        // We use center as we are dropping bubble based on center of bubble
        let centerPoint = bubble.getCenterOfBubble
        // Check if the center of the bubble is over the gameover line.
        guard centerPoint.y < gameoverHeight else {
            gameoverAction()
            return nil
        }

        // Check for collision
        if let collidedBubble = didCollideBubble {
            return dropBubbleDueToCollision(bubble: bubble, collidedBubble: collidedBubble)
        }

        guard let indexPath = delegate.getIndexPathAtPoint(point: centerPoint) else {
            // Game Over
            return nil
        }
        let index = indexPath.item
        bubble.index = index
        return delegate.setBubbleTypeAndGetPosition(bubbleType: bubble.bubbleType, index: index)
    }

    private func getStableBubbleIndex() -> [Int] {
        var result: [Int] = []
        for bubble in gameBubbles {
            if isStableBubble(bubble), let index = bubble.index {
                result.append(index)
            }
        }
        return result
    }

    func dropFiringBubble(
        bubble: GameBubble,
        collidedBubble: GameBubble? = nil,
        allowClearing: Bool = true) {

        bubble.velocity.stop()
        guard let dropPosition = dropBubble(bubble: bubble, didCollideBubble: collidedBubble) else {
            return
        }
        guard let index = bubble.index else {
            fatalError("If execution reaches here, bubble must have an index!")
        }
        renderEngine.derenderBubble(bubble)
        gameplayBubbles[index] = bubble
        if allowClearing {
            destroyBubble(bubble: bubble, destroyType: .matchThree)
        }
        bubble.setRenderingPosition(topLeftPoint: dropPosition)
    }
}

public enum CollisionType {
    case leftWall
    case rightWall
    case bubbleBubble
    case topWall
}

public enum RemovingBubbleType {
    case match
    case falling
    case instant
}

public enum DestroyType {
    case matchThree
}
