//
//  Vector.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 17/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import CoreGraphics

public class Vector {
    public var xDirection: CGFloat
    public var yDirection: CGFloat

    public init(xDirection: CGFloat, yDirection: CGFloat) {
        self.xDirection = xDirection
        self.yDirection = yDirection
    }

    public init(magnitude: CGFloat, angle: CGFloat) {
        xDirection = magnitude * sin(angle)
        yDirection = -magnitude * cos(angle)
    }

    public init() {
        xDirection = 0
        yDirection = 0
    }

    public var isNull: Bool {
        return xDirection == 0 && yDirection == 0
    }

    public static func dotProduct(vectorOne: Vector, vectorTwo: Vector) -> CGFloat {
        let newX = vectorOne.xDirection * vectorTwo.xDirection
        let newY = vectorOne.yDirection * vectorTwo.yDirection
        return newX + newY
    }

    public var magnitude: CGFloat {
        return sqrt(xDirection * xDirection + yDirection * yDirection)
    }

    public static func - (left: Vector, right: Vector) -> Vector {
        let newX = left.xDirection - right.xDirection
        let newY = left.yDirection - right.yDirection
        return Vector(xDirection: newX, yDirection: newY)
    }

    public static func * (left: CGFloat, right: Vector) -> Vector {
        return Vector(
            xDirection: right.xDirection * CGFloat(left),
            yDirection: right.yDirection * CGFloat(left))
    }

    public init(_ point: CGPoint) {
        xDirection = point.x
        yDirection = point.y
    }
}

extension Vector: Hashable {
    public static func == (lhs: Vector, rhs: Vector) -> Bool {
        return lhs.xDirection == rhs.xDirection && lhs.yDirection == lhs.yDirection
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(xDirection)
        hasher.combine(yDirection)
    }
}
