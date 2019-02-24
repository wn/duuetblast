//
//  GameBubble.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 10/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//
import Foundation
import CoreGraphics

public class GameBubble: GameObject {
    let diameter: CGFloat
    var velocity: Velocity = Velocity()
    var bubbleType: BubbleType
    var index: Int?
    var isFalling = false
    var acceleration = Acceleration()
    var inGrid: Bool {
        return index != nil
    }
    var lastCollidedBubble: GameBubble?

    init(position: CGPoint, diameter: CGFloat, type: BubbleType) {
        self.diameter = diameter
        self.bubbleType = type

        super.init(position: position)
    }

    func setVelocity(speed: CGFloat, angle: CGFloat) {
        velocity = Velocity(magnitude: speed, angle: angle)
    }

    /// Convert point from top left to center and rerender
    func setTopLeftPointToCenter(topLeftPoint: CGPoint) {
        let xCoordinate = topLeftPoint.x + radius
        let yCoordinate = topLeftPoint.y + radius
        position = CGPoint(x: xCoordinate, y: yCoordinate)
    }

    var radius: CGFloat {
        return diameter / 2
    }

    var getCenterOfBubble: CGPoint {
        return position
    }

    var getTopLeftOfBubble: CGPoint {
        let xCoordinate = position.x - radius
        let yCoordinate = position.y - radius
        return CGPoint(x: xCoordinate, y: yCoordinate)
    }

    var frame: CGRect {
        let topLeft = getTopLeftOfBubble
        return CGRect(x: topLeft.x, y: topLeft.y, width: diameter, height: diameter)
    }

    var movementType: MovementType {
        if velocity.isNull && acceleration.isNull {
            if inGrid {
                return .stationary
            } else {
                return .inCannon
            }
        } else {
            if isFalling {
                return .falling
            } else {
                return .moving
            }
        }
    }

    var isSpecialBubble: Bool {
        let specialBubbles: [BubbleType] = [.bomb, .indestructible, .star, .lightning]
        return specialBubbles.contains(bubbleType)
    }
}

enum MovementType {
    case inCannon
    case moving
    case falling
    case stationary
}
