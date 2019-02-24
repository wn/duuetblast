//
//  RenderEngine.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 13/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit

public class RenderEngine {
    private let diameter: CGFloat

    private var gameplayArea: UIView
    private lazy var cannonView: CannonView = CannonView(position: firingPosition, superView: gameplayArea)

    private var gameEngine: GameEngine

    internal var gameBubblesView: [GameBubble: GameBubbleView] = [:]

    init(gameEngine: GameEngine, gameplayArea: UIView, gameoverHeight: CGFloat) {
        self.gameEngine = gameEngine
        self.gameplayArea = gameplayArea
        diameter = gameEngine.bubbleDiameter
        cannonView.render()
        renderGameLine(height: gameoverHeight)
    }

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

    public func renderBubble(bubbleType: BubbleType) -> GameBubble {
        let bubble = GameBubble(position: firingPosition, diameter: diameter, type: bubbleType)
        let newBubbleView = GameBubbleView(
            position: firingPosition,
            imageURL: bubbleType.imageUrl,
            diameter: diameter)
        gameBubblesView[bubble] = newBubbleView
        gameplayArea.addSubview(newBubbleView.imageView)
        return bubble
    }

    public func renderFallingBubble(bubble: GameBubble, topLeftPosition: CGPoint) {
        guard gameBubblesView[bubble] == nil else {
            // Bubble already exist, dunnid render anymore
            return
        }
        //bubble.setTopLeftPointToCenter(topLeftPoint: topLeftPosition)
        let bubbleType = bubble.bubbleType
        let newBubbleView = GameBubbleView(
            position: bubble.position,
            imageURL: bubbleType.imageUrl,
            diameter: diameter)
        newBubbleView.fadedBubble()
        gameBubblesView[bubble] = newBubbleView
        gameplayArea.addSubview(newBubbleView.imageView)
    }

    public func rerenderBubble(gameBubble: GameBubble) {
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

    public func setAngle(angle: CGFloat) {
        cannonView.rotateAngle(angle)
    }

    public var firingPosition: CGPoint {
        let xCoordinate = gameplayArea.frame.width / 2
        let yCoordinate = gameplayArea.frame.height - gameBubbleRadius
        return CGPoint(x: xCoordinate, y: yCoordinate)
    }

    private var gameplayWidth: CGFloat {
        return gameplayArea.frame.width
    }

    private var gameplayHeight: CGFloat {
        return gameplayArea.frame.height
    }

    private var gameBubbleRadius: CGFloat {
        return gameEngine.bubbleRadius
    }
}
