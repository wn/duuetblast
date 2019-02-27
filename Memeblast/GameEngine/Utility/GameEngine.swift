//
//  GameEngine.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 10/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit
import AVFoundation

public class GameEngine: MusicPlayer {
    var audioPlayer: [AVAudioPlayer] = []

    private var gameBubbles = Set<GameBubble>()
    private var gameplayBubbles: [Int: GameBubble] = [:]
    var bubbleRadius: CGFloat
    let physicsEngine = PhysicsEngine()
    private let gameplayArea: UIView
    weak var gameDelegate: UIGameDelegate?
    private var renderEngine: RenderEngine
    var cannons: [CannonObject] = []
    lazy private var obstacles = generateObstacle()
    let gameLayout: GameLayout
    private let gameoverHeight: CGFloat
    private var gameOver = false
    private let FPS = 60.0
    private var refreshScreenTime: Double {
        return Double(1) / FPS
    }



    init(
        gameplayArea: UIView,
        radius: CGFloat,
        firingPosition: CGPoint,
        gameoverLine: CGFloat,
        gameLayout: GameLayout,
        isDualCannon: Bool) {

        self.gameplayArea = gameplayArea
        self.bubbleRadius = radius
        self.gameoverHeight = gameoverLine
        self.gameLayout = gameLayout

        renderEngine = RenderEngine(gameplayArea: gameplayArea, gameoverHeight: gameoverHeight, firingPosition: firingPosition, diameter: radius * 2)

        for cannonPosition in renderEngine.getCannonPositions(dual: isDualCannon) {
            let newCannon = CannonObject(position: cannonPosition)
            newCannon.setDelegate(gameEngine: self)
            cannons.append(newCannon)
        }
        renderEngine.renderCannon(cannons: cannons)
    }

    /// Spawn a firing bubble at firing point
    func generateFiringBubble(cannon: CannonObject) {
        guard !gameOver else {
            return
        }
        let nextBubbleType = getNextBubbleType()
        let newBubble = renderEngine.renderBubble(cannon: cannon, bubbleType: nextBubbleType)
        gameBubbles.insert(newBubble)
        cannon.loadBubble(newBubble)
    }

    /// Logic to fire a bubble towards `fireTowards`
    func fireBubble(fireTowards: CGPoint) {
        let firingCannon = renderEngine.setCannonAngle(fireTowards)
        guard fireTowards.y < renderEngine.firingPosition.y else {
            // Only allow the user to launch bubbles upwards.
            return
        }
        guard !gameOver else {
            return
        }

        guard let bubbleToFire = firingCannon.firingBubble else {
            return
        }

        guard collidedBubble(bubbleToFire) == nil else {
            return
        }

        // Play music
        audioPlayer = playSoundWith(musics: audioPlayer, filename: Constants.firing_sound, loop: 0, vol: 0.8)

        renderEngine.animateCannon(firingCannon)

        /// 0.5 is half of animation time
        /// TODO: Refactor 0.25 to be in constant file.
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.25) {
            firingCannon.fireBubble()
        }
    }

    func changeCannonAngle(_ angleTowards: CGPoint) {
        _ = renderEngine.setCannonAngle(angleTowards)
    }

    /// Logic to determine next bubble
    // TODO: Only generate bubbles that is in game
    private func getNextBubbleType() -> BubbleType {
        return Bubble.getRandomBubble()
    }

    func setupLevel(level: LevelGame) {
        // We assume a 1 to 1 maping, from index of grid to index of gridbubble in level.
        //let gridbubbles = level.gridBubbles
        for index in 0..<level.count where !level.isEmptyAtIndex(index: index) {
            guard let currPos = gameDelegate?.getPositionAtIndex(index: index) else {
                fatalError("Position from levelDesigner must be synchronized to gameEngine")
            }
            let type = level.getBubbleTypeAtIndex(index: index)
            let generatedBubble = GameBubble(position: currPos, diameter: bubbleDiameter, type: type)
            generatedBubble.index = index
            gameBubbles.insert(generatedBubble)
            gameplayBubbles[index] = generatedBubble
            generatedBubble.setTopLeftPointToCenter(topLeftPoint: currPos)
        }
        dropNonAttachedBubbles()
    }

    /// Check for collision with obstacles. If collision occur, execute obstacle action.
    private func obstacleCollisionAction(_ bubble: GameBubble) {
        for obstacle in obstacles where obstacle.didCollide(bubble: bubble) {
            obstacle.collideAction(bubble: bubble)
        }
    }

    /// Generate obstacles to be used in game engine
    private func generateObstacle() -> [Obstacle] {
        var result: [Obstacle] = []

        let leftWallFrame = CGRect(x: 0, y: 0, width: 0, height: gameplayArea.frame.height)
        let leftWallAction = {(bubble: GameBubble) in
            bubble.velocity.setXDirection(.positive)
            bubble.position.x = bubble.radius
            self.audioPlayer = self.playSoundWith(musics: self.audioPlayer, filename: Constants.bounce_wall, loop: 0, vol: 0.8)
        }
        let leftWall = Wall(frame: leftWallFrame, stable: false, action: leftWallAction)
        result.append(leftWall)

        let rightWallFrame = CGRect(
            x: gameplayArea.frame.width,
            y: 0,
            width: 0,
            height: gameplayArea.frame.height)
        let rightWallAction = {(bubble: GameBubble) in
            bubble.velocity.setXDirection(.negative)
            bubble.position.x = self.gameplayArea.frame.width - bubble.radius
            self.audioPlayer = self.playSoundWith(musics: self.audioPlayer, filename: Constants.bounce_wall, loop: 0, vol: 0.8)
        }
        let rightWall = Wall(frame: rightWallFrame, stable: false, action: rightWallAction)
        result.append(rightWall)

        let topWallFrame = CGRect(x: 0, y: 0, width: gameplayArea.frame.width, height: 0)
        let topWallAction = { (bubble: GameBubble) in
            bubble.position.y = self.bubbleRadius // In case bubble move too fast and theres no position to drop.
            self.dropFiringBubble(bubble: bubble)
        }
        let topWall = Wall(frame: topWallFrame, stable: true, action: topWallAction)
        result.append(topWall)

        return result
    }

    public func moveBubble(_ bubble: GameBubble) {
        bubble.position = physicsEngine.positionAfterTime(
            position: bubble.position,
            velocity: bubble.velocity,
            time: refreshScreenTime)
        bubble.velocity = physicsEngine.finalVelocity(
            velocity: bubble.velocity,
            acceleration: bubble.acceleration,
            time: refreshScreenTime)
        DispatchQueue.main.asyncAfter(deadline: .now() + refreshScreenTime) {
            self.renderEngine.rerenderBubble(gameBubble: bubble)
            self.movingFiringBubble(bubble)
        }
    }

    private func isBubbleOutOfGame(_ bubble: GameBubble) -> Bool {
        let outOfHorizontalBound =
            bubble.position.x < -bubbleRadius
                || bubble.position.x > gameplayArea.frame.width + bubbleRadius
        let outOfVerticalBound =
            bubble.position.y < -bubbleRadius
                || bubble.position.y > gameplayArea.frame.height + bubbleRadius
        return outOfHorizontalBound || outOfVerticalBound
    }

    /// Get first bubble where collision did happen.
    public func collidedBubble(_ bubble: GameBubble) -> GameBubble? {
        return gameBubbles.first {
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

    public func movingFiringBubble(_ bubble: GameBubble) {
        guard gameBubbles.contains(bubble) else {
            renderEngine.derenderBubble(bubble)
            return
        }
        switch bubble.movementType {
        case .falling:
            if isBubbleOutOfGame(bubble) {
                gameBubbles.remove(bubble)
                renderEngine.derenderBubble(bubble)
                return
            }
        case .moving:
            collisionWithBubble(bubble: bubble)
        case .stationary:
            return
        case .inCannon:
            fatalError("Bubble in cannon shouldn't be moving!")
        }
        moveBubble(bubble)
    }

    private func collisionWithBubble(bubble: GameBubble) {
        if let collidedBubble = collidedBubble(bubble) {
            switch collidedBubble.movementType {
            case .falling:
                break
            case .stationary:
                dropFiringBubble(bubble: bubble, collidedBubble: collidedBubble)

                activatePower(collidedBubble: collidedBubble, collidee: bubble)
                // Check if winning condition met
                activateWinningActionIfWin()
                return
            case .moving:
                // Guard against multiple collision with the same object
                guard bubble.lastCollidedBubble != collidedBubble else {
                    break
                }
                bubble.lastCollidedBubble = collidedBubble
                collidedBubble.lastCollidedBubble = bubble

                collisionLogic(bubbleOne: bubble, bubbleTwo: collidedBubble)
            case .inCannon:
                return
            }
        } else {
            bubble.lastCollidedBubble = nil
        }
        obstacleCollisionAction(bubble)
    }

    var wonGame: Bool {
        for (_, bubble) in gameplayBubbles {
            let type = bubble.bubbleType
            if type.isNormalBubble || type.isPowerBubble {
                return false
            }
        }
        print("WON GAME")
        return true
    }

    private func activateWinningActionIfWin() {
        guard wonGame else {
            return
        }
        completedGame(.falling)
        let alert = UIAlertController(title: "YAY YOU WON", message: "WANNA RESTART?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "CONFIRM", style: .default) {
            _ in
            self.gameDelegate?.restartLevel()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        gameDelegate?.present(alert, animated: true)
    }

    private func activatePower(collidedBubble: GameBubble, collidee: GameBubble) {
        guard let index = collidedBubble.index else {
            return
        }
        if collidedBubble.isSpecialBubble {
            switch collidedBubble.bubbleType {
            case .lightning:
                audioPlayer = playSoundWith(musics: audioPlayer, filename: Constants.zap_sound, loop: 0, vol: 0.8)
                let rows = gameLayout.getRowIndexes(index)
                for bubbleIndex in rows {
                    if let rowBubble = gameplayBubbles[bubbleIndex] {
                        deregisterBubble(bubble: rowBubble, type: .falling)
                    }
                }
            case .bomb:
                audioPlayer = playSoundWith(musics: audioPlayer, filename: Constants.bomb_sound, loop: 0, vol: 0.8)
                let rows = gameLayout.getNeighboursAtIndex(index)
                for bubbleIndex in rows {
                    if let rowBubble = gameplayBubbles[bubbleIndex] {
                        deregisterBubble(bubble: rowBubble, type: .match)
                    }
                }
                deregisterBubble(bubble: collidedBubble, type: .match)
            case .star:
                for bubble in gameBubbles {
                    if bubble.bubbleType == collidee.bubbleType {
                        deregisterBubble(bubble: bubble, type: .match)
                    }
                }
                deregisterBubble(bubble: collidedBubble, type: .match)
            default:
                // Non-special bubbles or indestructible.
                break
            }
            dropNonAttachedBubbles()
        }
    }

    private func collisionLogic(bubbleOne: GameBubble, bubbleTwo: GameBubble) {
        let finalVelocities = physicsEngine.velocityAfterCollisionTwoDimension(
            velocityOne: bubbleOne.velocity,
            positionOne: bubbleOne.position,
            velocityTwo: bubbleTwo.velocity,
            positionTwo: bubbleTwo.position)
        bubbleOne.velocity = finalVelocities.0
        bubbleTwo.velocity = finalVelocities.1
    }

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
        toDestroy.forEach { deregisterBubble(bubble: $0, type: .match) }
    }

    // Only game engine can deregister bubble from game
    private func deregisterBubble(bubble: GameBubble, type: RemovingBubbleType) {
        switch type {
        case .falling:
            setFreefallBubble(bubble)
        case .match:
            gameBubbles.remove(bubble)
        }
        removeBubbleFromGrid(bubble)
    }

    /// Set bubble to be in free fall.
    internal func setFreefallBubble(_ bubble: GameBubble) {
        bubble.velocity.stop()

        // Gravity
        bubble.acceleration = Acceleration.gravity
        bubble.isFalling = true
        renderEngine.renderFallingBubble(bubble: bubble, topLeftPosition: bubble.position)
        movingFiringBubble(bubble)
    }

    private func removeBubbleFromGrid(_ bubble: GameBubble) {
        guard let delegate = gameDelegate, let index = bubble.index else {
            return
        }
        gameplayBubbles[index] = nil
        delegate.currentLevel.setBubbleTypeAtIndex(index: index, bubbleType: .invisible)
        delegate.reload(index: index)
    }

    private func isAttachedBubbles() -> Set<GameBubble> {
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

    private func getStableBubbleIndex() -> [Int] {
        var result: [Int] = []
        for bubble in gameBubbles {
            if isStableBubble(bubble), let index = bubble.index {
                result.append(index)
            }
        }
        return result
    }

    private func dropNonAttachedBubbles() {
        let attachedBubbles = isAttachedBubbles()
        let nonAttachedBubbles = gameBubbles.filter { !attachedBubbles.contains($0) && $0.movementType == .stationary }
        for bubble in nonAttachedBubbles {
            deregisterBubble(bubble: bubble, type: .falling)
        }
        //nonAttachedBubbles.forEach { deregisterBubble(bubble: $0, type: .falling) }
    }

    private func isStableBubble(_ bubble: GameBubble) -> Bool {
        return obstacles.contains { $0.stable && $0.didCollide(bubble: bubble) }
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
        bubble.index = indexPath.item
        return delegate.setBubbleTypeAndGetPosition(bubbleType: bubble.bubbleType, indexPath: indexPath)
    }

    private func gameoverAction() {
        audioPlayer = playSoundWith(musics: audioPlayer, filename: Constants.gameover_sound, loop: 0, vol: 0.8)
        // Must fall, or else bubble that just dropped will not have an index + no speed, causing it to be 'in-cannon'
        completedGame(.falling)
        guard let gameDelegate = gameDelegate else {
            return
        }
        let alert = UIAlertController(
            title: "Game Over!",
            message: "Do you want to restart the game?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sure", style: .default) { _ in
            gameDelegate.restartLevel()
        })
        gameDelegate.present(alert, animated: true)
    }

    private func dropFiringBubble(bubble: GameBubble, collidedBubble: GameBubble? = nil) {
        bubble.velocity.stop()
        guard let dropPosition = dropBubble(bubble: bubble, didCollideBubble: collidedBubble) else {
            return
        }
        guard let index = bubble.index else {
            fatalError("If execution reaches here, bubble must have an index!")
        }
        renderEngine.derenderBubble(bubble)
        gameplayBubbles[index] = bubble
        destroyBubble(bubble: bubble, destroyType: .matchThree)
        bubble.setTopLeftPointToCenter(topLeftPoint: dropPosition)
    }

    /// Reinit all variables.
    public func restartEngine() {
        completedGame(.match)
        renderEngine.resetCannon()
        print("restart")
        gameOver = false
    }

    private func completedGame(_ type: RemovingBubbleType) {
        gameOver = true
        for bubble in gameBubbles {
            deregisterBubble(bubble: bubble, type: type)
        }
        // gameBubbles = Set<GameBubble>()
        gameplayBubbles = [:]
    }

    public var bubbleDiameter: CGFloat {
        return bubbleRadius * 2
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
}

public enum DestroyType {
    case matchThree
}
