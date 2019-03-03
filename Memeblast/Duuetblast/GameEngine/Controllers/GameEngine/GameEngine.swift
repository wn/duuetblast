//
//  GameEngine.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 10/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit
import AVFoundation
import WNPhysicsEngine
import PopupDialog

public class GameEngine {
    // MARK: - Properties
    var gameBubbles = Set<GameBubble>()
    var gameplayBubbles: [Int: GameBubble] = [:]
    var bubbleRadius: CGFloat
    let physicsEngine = PhysicsEngine()
    private let gameplayArea: UIView
    weak var gameDelegate: UIGameDelegate?
    var renderEngine: RenderEngine
    var cannons: [CannonObject] = []
    lazy var obstacles = generateObstacle()
    let gameLayout: GameLayout
    let gameoverHeight: CGFloat
    var gameOver = false
    private let FPS = Constants.FPS
    private var refreshScreenTime: Double {
        return Double(1) / FPS
    }
    public var bubbleDiameter: CGFloat {
        return bubbleRadius * 2
    }

    // MARK: - Instantiation method
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
        generateChainBubble()
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
            generatedBubble.setRenderingPosition(topLeftPoint: currPos)
        }

        // Features :)
        generateChainBubble()
        spawnRandomBubble(time: Constants.randomBubbleInterval)
        startTimer(seconds: level.time)
        gameDelegate?.score = Constants.initialScore
        dropNonAttachedBubbles()
    }

    // MARK: - Bubble creation and firing mechanics:
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
        guard let firingCannon = renderEngine.setCannonAngle(fireTowards) else {
            // Ensure that renderEngine can set angle.
            return
        }
        guard !gameOver,
            let bubbleToFire = firingCannon.firingBubble,
            collidedBubble(bubbleToFire) == nil else {
            // Guard against gameover, cannon contains bubble and no other bubble is touching the cannon.
            return
        }

        // Play music
        Settings.playSoundWith(Constants.firingSound)

        renderEngine.animateCannon(firingCannon)
        gameDelegate?.score -= Constants.firingBubblePoints
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + Constants.cannonDelay / 2) {
            firingCannon.fireBubble()
        }
    }

    func changeCannonAngle(_ angleTowards: CGPoint) {
        _ = renderEngine.setCannonAngle(angleTowards)
    }

    /// Logic to determine next bubble
    private func getNextBubbleType() -> BubbleType {
        if arc4random_uniform(10) < 1 {
            return .rocket
        }
        return Bubble.getRandomBubble()
    }

    // MARK: - Level designer Features
    func startTimer(seconds: Int) {
        guard let gameDelegate = gameDelegate, !gameOver else {
            return
        }
        guard abs(seconds - gameDelegate.timeValue) <= 1 else {
            // Guard against restarting level
            return
        }

        gameDelegate.timeValue = seconds
        if seconds <= 0 {
            gameoverAction()
            return
        }
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
            self.startTimer(seconds: seconds - 1)
        }
    }

    /// Randomly spawn a connected bubble
    func spawnRandomBubble(time: Double) {
        guard !gameOver else {
            return
        }
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + time) { [weak self] () in
            guard let strongself = self else {
                return
            }
            var connected = strongself.isAttachedBubbles()
            while let bubble = connected.randomElement(), let index = bubble.index {
                guard strongself.gameplayBubbles.count < strongself.gameLayout.totalNumberOfBubble else {
                    strongself.gameoverAction()
                    return
                }
                let emptyIndexes = strongself.getEmptyNeighbouringIndex(index)
                guard emptyIndexes.count > 0 else {
                    connected.remove(bubble)
                    break
                }
                guard
                    let randomIndex = emptyIndexes.randomElement(),
                    let randomElement = BubbleType.getNormalBubbles.randomElement(),
                    let delegate = strongself.gameDelegate,
                    let position = delegate.setBubbleTypeAndGetPosition(
                        bubbleType: randomElement,
                        index: randomIndex) else {
                    break
                }
                let newBubble = GameBubble(position: CGPoint(), diameter: strongself.bubbleDiameter, type: randomElement)
                newBubble.setRenderingPosition(topLeftPoint: position)
                strongself.gameBubbles.insert(newBubble)
                strongself.dropFiringBubble(bubble: newBubble, allowClearing: false)
                break
            }
            strongself.spawnRandomBubble(time: time)
        }
    }

    func generateChainBubble() {
        // We need to get center position of bubble just below gameover line
        let pos = CGPoint(x: bubbleRadius, y: gameoverHeight + bubbleRadius)
        let chainBubble = renderEngine.renderBubble(position: pos, bubbleType: .chainsawBubble)
        chainBubble.setVelocity(speed: 200, angle: CGFloat.pi / 2)
        // TODO: Remove hard coding

        gameBubbles.insert(chainBubble)
        moveBubble(chainBubble)
    }

    // MARK: - Obstacles logic

    /// Check for collision with obstacles. If collision occur, execute obstacle action.
    func obstacleCollisionAction(_ bubble: GameBubble) {
        // Rockets not affected by obstacles!
        guard bubble.bubbleType != .rocket else {
            return
        }
        obstacles.filter { $0.didCollide(bubble: bubble) }.forEach { $0.collideAction(bubble: bubble) }
    }

    /// Generate obstacles to be used in game engine
    private func generateObstacle() -> [Obstacle] {
        var result: [Obstacle] = []

        let leftWallFrame = CGRect(x: 0, y: 0, width: 0, height: gameplayArea.frame.height)
        let leftWallAction = {(bubble: GameBubble) in
            bubble.velocity.setXDirection(.positive)
            bubble.position.x = bubble.radius
            if bubble.bubbleType.isNormalBubble {
                Settings.playSoundWith(Constants.bounceWall)
            }
        }
        let leftWall = Wall(frame: leftWallFrame, stable: false, action: leftWallAction)
        result.append(leftWall)

        let rightWallFrame = CGRect(
            x: gameplayArea.frame.width,
            y: 0,
            width: 0,
            height: gameplayArea.frame.height)
        let rightWallAction = {[weak self] (bubble: GameBubble) in
            guard let strongSelf = self else { return }
            bubble.velocity.setXDirection(.negative)
            bubble.position.x = strongSelf.gameplayArea.frame.width - bubble.radius
            if bubble.bubbleType.isNormalBubble {
                Settings.playSoundWith(Constants.bounceWall)
            }
        }
        let rightWall = Wall(frame: rightWallFrame, stable: false, action: rightWallAction)
        result.append(rightWall)

        let topWallFrame = CGRect(x: 0, y: 0, width: gameplayArea.frame.width, height: 0)
        let topWallAction = { [weak self] (bubble: GameBubble) in
            bubble.position.y = self?.bubbleRadius ?? 0 // In case bubble move too fast and theres no position to drop.
            self?.dropFiringBubble(bubble: bubble)
            Settings.playSoundWith(Constants.bubbleDropSound)
        }
        let topWall = Wall(frame: topWallFrame, stable: true, action: topWallAction)
        result.append(topWall)

        return result
    }

    // MARK: - Bubble movements logic
    public func moveBubble(_ bubble: GameBubble) {
        guard gameBubbles.count > 0 else {
            return
        }
        bubble.position = physicsEngine.positionAfterTime(
            position: bubble.position,
            velocity: bubble.velocity,
            time: refreshScreenTime)
        bubble.velocity = physicsEngine.finalVelocity(
            velocity: bubble.velocity,
            acceleration: bubble.acceleration,
            time: refreshScreenTime)
        DispatchQueue.main.asyncAfter(deadline: .now() + refreshScreenTime) {
            self.renderEngine.rerenderBubble(bubble)
            self.movingFiringBubble(bubble)
        }
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

    private func isBubbleOutOfGame(_ bubble: GameBubble) -> Bool {
        let outOfHorizontalBound =
            bubble.position.x < -bubbleRadius
                || bubble.position.x > gameplayArea.frame.width + bubbleRadius
        let outOfVerticalBound =
            bubble.position.y < -bubbleRadius
                || bubble.position.y > gameplayArea.frame.height + bubbleRadius
        return outOfHorizontalBound || outOfVerticalBound
    }

    func activatePower(collidedBubble: GameBubble, collidee: GameBubble) {
        guard let index = collidedBubble.index else {
            return
        }
        guard collidedBubble.bubbleType.isPowerBubble else {
            return
        }
        switch collidedBubble.bubbleType {
        case .lightning:
            Settings.playSoundWith(Constants.zapSound)
            let rows = gameLayout.getRowIndexes(index)
            for bubbleIndex in rows {
                if let rowBubble = gameplayBubbles[bubbleIndex] {
                    deregisterBubble(bubble: rowBubble, type: .falling)
                    if rowBubble.bubbleType.isPowerBubble && rowBubble != collidedBubble {
                        activatePower(collidedBubble: rowBubble, collidee: collidedBubble)
                    }
                    gameDelegate?.score += Constants.lightningPoints
                }
            }
        case .bomb:
            Settings.playSoundWith(Constants.bombSound)
            let rows = gameLayout.getNeighboursAtIndex(index)
            // We destroy the bomb first.
            deregisterBubble(bubble: collidedBubble, type: .match)
            for bubbleIndex in rows {
                if let rowBubble = gameplayBubbles[bubbleIndex] {
                    if rowBubble.bubbleType.isPowerBubble {
                        activatePower(collidedBubble: rowBubble, collidee: collidedBubble)
                    } else {
                        deregisterBubble(bubble: rowBubble, type: .match)
                    }
                    gameDelegate?.score += Constants.bombPoints
                }
            }
            deregisterBubble(bubble: collidedBubble, type: .match)
        case .star:
            Settings.playSoundWith(Constants.bombSound)
            for bubble in gameBubbles where bubble.movementType == .stationary {
                if bubble.bubbleType == collidee.bubbleType {
                    if bubble.bubbleType.isPowerBubble {
                        activatePower(collidedBubble: bubble, collidee: collidedBubble)
                    } else {
                        deregisterBubble(bubble: bubble, type: .match)
                    }
                    gameDelegate?.score += Constants.starBubblePoints
                }
            }
            deregisterBubble(bubble: collidedBubble, type: .match)
        case .random:
            guard collidee.bubbleType.isNormalBubble else {
                deregisterBubble(bubble: collidedBubble, type: .match)
                break
            }
            let randomBubbleType = BubbleType.getRandomBubble
            collidedBubble.bubbleType = randomBubbleType
            _ = gameDelegate?.setBubbleTypeAndGetPosition(bubbleType: randomBubbleType, index: index)
        case .bin:
            deregisterBubble(bubble: collidedBubble, type: .match)
            deregisterBubble(bubble: collidee, type: .match)
            gameDelegate?.score += Constants.binBubblePoints
        default:
            // Non-special bubbles or indestructible.
            break
        }
        dropNonAttachedBubbles()
    }

    // MARK: - Endgame mechanics
    func gameoverAction() {
        guard !gameOver else {
            return
        }
        Settings.playSoundWith(Constants.gameoverSound)
        // Must fall, or else bubble that just dropped will not have an
        // index + no speed, causing it to be 'in-cannon'
        completedGame(.falling)
        alertScore()
    }

    private var wonGame: Bool {
        guard !gameOver else {
            return false
        }
        for (_, bubble) in gameplayBubbles {
            let type = bubble.bubbleType
            if type.isNormalBubble || type.isPowerBubble {
                return false
            }
        }
        return true
    }

    func activateWinningActionIfWin() {
        guard wonGame, let gameDelegate = gameDelegate else {
            return
        }
        completedGame(.falling)
        gameDelegate.score += gameDelegate.timeValue * Constants.extraTimePoints
        gameDelegate.timeValue = 0

        alertScore()
    }

    func alertScore() {
        guard let gameDelegate = gameDelegate else {
            return
        }
        guard gameDelegate.currentLevel.levelName != nil else {
            unsavedGameAlert()
            return
        }
        if gameDelegate.saveScore() {
            newHighscoreAlert()
        } else {
            didntBreakHighscoreAlert()
        }
    }

    // MARK: - Restart game engine logic
    public func restartEngine() {
        completedGame(.match)
        renderEngine.resetCannon()
        gameOver = false
    }

    func completedGame(_ type: RemovingBubbleType) {
        gameOver = true
        gameBubbles.forEach { deregisterBubble(bubble: $0, type: type) }
        gameplayBubbles = [:]
    }
}
