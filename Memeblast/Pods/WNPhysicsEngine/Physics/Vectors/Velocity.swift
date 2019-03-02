//
//  Velocity.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 10/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit

public class Velocity: Vector {
    public func changeXDirection() {
        xDirection *= -1
    }

    public func setXDirection(_ direction: MoveDirection) {
        switch direction {
        case .positive:
            xDirection = abs(xDirection)
        case .negative:
            xDirection = -abs(xDirection)
        }
    }

    public func stop() {
        xDirection = 0
        yDirection = 0
    }

    public static func vectorToVelocity(vector: Vector) -> Velocity {
        return Velocity(xDirection: vector.xDirection, yDirection: vector.yDirection)
    }

    public static func - (left: Velocity, right: Velocity) -> Velocity {
        let newX = left.xDirection - right.xDirection
        let newY = left.yDirection - right.yDirection
        return Velocity(xDirection: newX, yDirection: newY)
    }

    public static func + (left: Velocity, right: Velocity) -> Velocity {
        let newX = left.xDirection + right.xDirection
        let newY = left.yDirection + right.yDirection
        return Velocity(xDirection: newX, yDirection: newY)
    }
}

public enum MoveDirection {
    case positive
    case negative
}
