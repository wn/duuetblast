//
//  RenderEngine.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 13/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit
import WNPhysicsEngine

public class RenderEngine {
    private let diameter: CGFloat
    unowned private var gameplayArea: UIView
    var firingPosition: CGPoint
    let physicsEngine = PhysicsEngine()
    var cannonsView: [CannonView] = []

    var gameBubblesView: [GameBubble: GameBubbleView] = [:]
    var cannonsViewMap: [CannonObject: CannonView] = [:]

    init(gameplayArea: UIView, gameoverHeight: CGFloat, firingPosition: CGPoint, diameter: CGFloat) {
        self.gameplayArea = gameplayArea
        self.firingPosition = firingPosition
        self.diameter = diameter
        renderGameLine(height: gameoverHeight)
    }

    // MARK: - Methods for rendering cannon
    func renderCannon(cannons: [CannonObject]) {
        for cannon in cannons {
            let newView = CannonView(position: cannon.position, superView: gameplayArea)
            cannonsViewMap[cannon] = newView
            cannonsView.append(newView)
        }
    }

    private func rerenderCannon(_ cannon: CannonObject) {
        guard let cannonView = cannonsViewMap[cannon] else {
            return
        }
        cannonView.rotateAngle(cannon.angle)
    }

    func resetCannon() {
        for (cannon, _) in cannonsViewMap {
            guard let bubble = cannon.firingBubble else {
                return
            }
            cannon.firingBubble = nil
            derenderBubble(bubble)
        }
    }

    private func getClosestCannon(_ point: CGPoint) -> CannonObject {
        var displacement = CGFloat.infinity
        // Get cannon closest to the point
        var closestCannon: CannonObject? = nil
        for (cannon, cannonView) in cannonsViewMap {
            let position = cannonView.firingPosition
            let currDisplacement =  point.displacementTo(point: position)
            if currDisplacement < displacement {
                displacement = currDisplacement
                closestCannon = cannon
            }
        }
        return closestCannon!
    }

    func setCannonAngle(_ towards: CGPoint) -> CannonObject? {
        let closestCannon = getClosestCannon(towards)
        guard let cannonView = cannonsViewMap[closestCannon] else {
            fatalError("Cannon should exist in view!")
        }
        guard towards.y < cannonView.firingPosition.y else {
            // Ensure that we are firing above the cannon.
            return nil
        }
        let newAngle = physicsEngine.getBearing(startPoint: towards, endPoint: cannonView.firingPosition)
        closestCannon.setAngle(newAngle)
        rerenderCannon(closestCannon)
        return closestCannon
    }

    func getCannonPositions(dual: Bool) -> [CGPoint] {
        if dual {
            let quarterMark = gameplayArea.frame.width / 4
            let leftPosition = firingPosition.shiftHorizontal(-quarterMark)
            let rightPosition = firingPosition.shiftHorizontal(quarterMark)
            return [leftPosition, rightPosition]
        } else {
            return [firingPosition]
        }
    }

    // MARK: - Methods for rendering game line

    private func renderGameLine(height: CGFloat) {
        let lineDashPattern: [NSNumber]  = [10,40] // [size per dash, size per blank]

        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.lineDashPattern = lineDashPattern

        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: height),
                                CGPoint(x: gameplayWidth, y: height)])

        shapeLayer.path = path
        gameplayArea.layer.addSublayer(shapeLayer)
    }

    public func animateCannon(_ cannon: CannonObject) {
        guard let view = cannonsViewMap[cannon] else {
            return
        }
        view.animate()
    }

    // MARK: - Methods for rendering bubbles
    public func renderBubble(cannon: CannonObject, bubbleType: BubbleType) -> GameBubble {
        guard let cannonView = cannonsViewMap[cannon] else {
            fatalError("non gameplay cannon shouldnt be rendering bubbles!")
        }
        let firePosition = cannonView.firingPosition
        let renderedBubble = renderBubble(position: firePosition, bubbleType: bubbleType)
        return renderedBubble
    }

    public func renderBubble(position: CGPoint, bubbleType: BubbleType) -> GameBubble {
        let bubble = GameBubble(position: position, diameter: diameter, type: bubbleType)
        let newBubbleView = GameBubbleView(
            position: bubble.getRenderingPosition,
            imageUrl: Settings.selectedTheme.getBubbleTypePath(type: bubbleType),
            diameter: diameter)
        gameBubblesView[bubble] = newBubbleView
        gameplayArea.addSubview(newBubbleView.imageView)
        gameplayArea.sendSubviewToBack(newBubbleView.imageView)
        return bubble
    }

    public func rerenderBubble(_ gameBubble: GameBubble) {
        guard let bubbleView = gameBubblesView[gameBubble] else {
            return
        }
        bubbleView.position = gameBubble.position
        bubbleView.rerender()
    }

    public func derenderBubble(_ bubble: GameBubble) {
        guard let bubbleView = gameBubblesView[bubble] else {
            return
        }
        bubbleView.imageView.removeFromSuperview()
        gameBubblesView[bubble] = nil
    }

    public func renderFallingBubble(bubble: GameBubble, topLeftPosition: CGPoint) {
        guard gameBubblesView[bubble] == nil else {
            // Bubble already exist, dunnid render anymore
            return
        }
        //bubble.setTopLeftPointToCenter(topLeftPoint: topLeftPosition)
        let bubbleType = bubble.bubbleType
        let newBubbleView = GameBubbleView(
            position: bubble.getRenderingPosition,
            imageUrl: Settings.selectedTheme.getBubbleTypePath(type: bubbleType),
            diameter: diameter)
        newBubbleView.fadedBubble()
        gameBubblesView[bubble] = newBubbleView
        gameplayArea.addSubview(newBubbleView.imageView)
    }

    // MARK: - Helper properties

    private var gameplayWidth: CGFloat {
        return gameplayArea.frame.width
    }

    private var gameplayHeight: CGFloat {
        return gameplayArea.frame.height
    }

    private var gameBubbleRadius: CGFloat {
        return diameter / 2
    }
}

extension CGPoint {
    func shiftHorizontal(_ by: CGFloat) -> CGPoint {
        let newX = self.x + by
        let newY = self.y
        return CGPoint(x: newX, y: newY)
    }
}


