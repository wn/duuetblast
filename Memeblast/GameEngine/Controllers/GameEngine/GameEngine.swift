//
//  GameEngine.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 10/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit
import AVFoundation

public class GameEngine {
    // MARK: - Properties
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
    var gameOver = false
    private let FPS = 60.0
    private var refreshScreenTime: Double {
        return Double(1) / FPS
    }
    public var bubbleDiameter: CGFloat {
        return bubbleRadius * 2
    }

    deinit {
        print("DEINITED GAME ENGINE")
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

        // TODO: FEATURES!!!!!!!!
        // HAVE FLAG IN LEVEL SELECTOR
        generateChainBubble()
        spawnRandomBubble()
        startTimer(seconds: 10)

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
        Settings.playSoundWith(Constants.firing_sound)

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
    /// TODO: Only generate bubbles that is in game
    private func getNextBubbleType() -> BubbleType {
        if arc4random_uniform(10) < 1 {
            return .rocket
        }
        return Bubble.getRandomBubble()
    }

    // MARK: - Level designer Features
    func startTimer(seconds: Int) {
        guard !gameOver else {
            return
        }
        gameDelegate?.setTime(seconds: seconds)
        if seconds <= 0 {
            print("TIMESUP")
            gameoverAction()
            return
        }
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
            self.startTimer(seconds: seconds - 1)
        }
    }

    /// Randomly spawn a connected bubble
    func spawnRandomBubble() {
        guard !gameOver else {
            return
        }
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 5.0) { [weak self] () in
            guard let strongself = self else { return }
            var connected = strongself.isAttachedBubbles()
            while let bubble = connected.randomElement(), let index = bubble.index {
                guard strongself.gameplayBubbles.count < strongself.gameLayout.totalNumberOfBubble else {
                    print("FULL BOARD")
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
                    let position = delegate.setBubbleTypeAndGetPosition(bubbleType: randomElement, index: randomIndex) else {
                    break
                }
                let newBubble = GameBubble(position: CGPoint(), diameter: strongself.bubbleDiameter, type: randomElement)
                newBubble.setRenderingPosition(topLeftPoint: position)
                strongself.gameBubbles.insert(newBubble)
                strongself.dropFiringBubble(bubble: newBubble, allowClearing: false)
                break
            }

            strongself.spawnRandomBubble()
        }
    }

    func generateChainBubble() {
        // We need to get center position of bubble just below gameover line
        let pos = CGPoint(x: bubbleRadius, y: gameoverHeight + bubbleRadius)
        let chainBubble = renderEngine.renderBubble(position: pos, bubbleType: .chainsaw_bubble)
        chainBubble.setVelocity(speed: 200, angle: CGFloat.pi / 2)
        // TODO: Remove hard coding

        gameBubbles.insert(chainBubble)
        moveBubble(chainBubble)
    }

    // MARK: - Obstacles logic

    /// Check for collision with obstacles. If collision occur, execute obstacle action.
    private func obstacleCollisionAction(_ bubble: GameBubble) {
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
                Settings.playSoundWith(Constants.bounce_wall)
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
                Settings.playSoundWith(Constants.bounce_wall)
            }
        }
        let rightWall = Wall(frame: rightWallFrame, stable: false, action: rightWallAction)
        result.append(rightWall)

        let topWallFrame = CGRect(x: 0, y: 0, width: gameplayArea.frame.width, height: 0)
        let topWallAction = { [weak self] (bubble: GameBubble) in
            bubble.position.y = self?.bubbleRadius ?? 0 // In case bubble move too fast and theres no position to drop.
            self?.dropFiringBubble(bubble: bubble)
        }
        let topWall = Wall(frame: topWallFrame, stable: true, action: topWallAction)
        result.append(topWall)

        return result
    }

    // MARK: - Bubble movements logic
    public func moveBubble(_ bubble: GameBubble) {
        guard gameBubbles.count > 0 else {
            print("COMPLETED")
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

    // MARK: - Collision mechanics

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

    private func collisionWithBubble(bubble: GameBubble) {
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
                guard bubble.bubbleType != .chainsaw_bubble && collidedBubble.bubbleType != .chainsaw_bubble else {
                    Settings.playSoundWith(Constants.chainsaw_sound)
                    print("HIT CHAINSAW")
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

    private func activatePower(collidedBubble: GameBubble, collidee: GameBubble) {
        guard let index = collidedBubble.index else {
            return
        }
        guard collidedBubble.bubbleType.isPowerBubble else {
            return
        }
        switch collidedBubble.bubbleType {
        case .lightning:
            Settings.playSoundWith(Constants.zap_sound)
            let rows = gameLayout.getRowIndexes(index)
            for bubbleIndex in rows {
                if let rowBubble = gameplayBubbles[bubbleIndex] {
                    deregisterBubble(bubble: rowBubble, type: .falling)
                }
            }
        case .bomb:
            Settings.playSoundWith(Constants.bomb_sound)
            let rows = gameLayout.getNeighboursAtIndex(index)
            for bubbleIndex in rows {
                if let rowBubble = gameplayBubbles[bubbleIndex] {
                    deregisterBubble(bubble: rowBubble, type: .match)
                }
            }
            deregisterBubble(bubble: collidedBubble, type: .match)
        case .star:
            // TODO: star music
            Settings.playSoundWith(Constants.bomb_sound)
            for bubble in gameBubbles where bubble.movementType == .stationary {
                if bubble.bubbleType == collidee.bubbleType{
                    deregisterBubble(bubble: bubble, type: .match)
                }
            }
            deregisterBubble(bubble: collidedBubble, type: .match)
        case .random:
            // TODO: generate random bubble
            // TODO: MUSIC
            let randomBubbleType = BubbleType.getRandomBubble
            collidedBubble.bubbleType = randomBubbleType
            _ = gameDelegate?.setBubbleTypeAndGetPosition(bubbleType: randomBubbleType, index: index)
        case .magnet:
            // TODO
            // Probably check in movingBubble
            print("affected by magnet")
        case .bin:
            // TODO: MUSIC
            deregisterBubble(bubble: collidedBubble, type: .match)
            deregisterBubble(bubble: collidee, type: .match)
        default:
            // Non-special bubbles or indestructible.
            break
        }
        dropNonAttachedBubbles()
    }

    // MARK: - Endgame mechanics
    private func gameoverAction() {
        Settings.playSoundWith(Constants.gameover_sound)
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

    private var wonGame: Bool {
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
        weak var gameEngine = self
        alert.addAction(UIAlertAction(title: "CONFIRM", style: .default) { _ in
            gameEngine?.gameDelegate?.restartLevel()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        gameDelegate?.present(alert, animated: true)
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
        toDestroy.forEach { deregisterBubble(bubble: $0, type: .match) }
    }

    // Only game engine can deregister bubble from game
    private func deregisterBubble(bubble: GameBubble, type: RemovingBubbleType) {
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

    private func isStableBubble(_ bubble: GameBubble) -> Bool {
        return obstacles.contains { $0.stable && $0.didCollide(bubble: bubble) }
    }

    private func dropNonAttachedBubbles() {
        let attachedBubbles = isAttachedBubbles()
        let nonAttachedBubbles = gameBubbles.filter { !attachedBubbles.contains($0) && $0.movementType == .stationary }
        nonAttachedBubbles.forEach { deregisterBubble(bubble: $0, type: .falling) }

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
            print("WENT OVER LINE")
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

    private func dropFiringBubble(
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

    // MARK: - Restart game engine logic
    public func restartEngine() {
        completedGame(.match)
        renderEngine.resetCannon()
        print("restart")
        gameOver = false
    }

    func completedGame(_ type: RemovingBubbleType) {
        gameOver = true
        gameBubbles.forEach { deregisterBubble(bubble: $0, type: type) }
        gameplayBubbles = [:]
    }
}

// TODO: Refactor to new class
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
