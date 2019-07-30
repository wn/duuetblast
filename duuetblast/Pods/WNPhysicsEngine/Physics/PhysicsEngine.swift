//
//  PhysicsEngine.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 10/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import CoreGraphics

public class PhysicsEngine {
    public init() {

    }

    /// Convert collision velocity based on the Principle of Conservation of Linear Momentum (2D).
    /// Assume equal mass of 1kg.
    public func velocityAfterCollisionTwoDimension(
        velocityOne: Velocity,
        positionOne: CGPoint,
        velocityTwo: Velocity,
        positionTwo: CGPoint) -> (Velocity, Velocity) {

        let centerOneToCenterTwoVector = Vector(positionOne) - Vector(positionTwo)
        let velocityOneDiffTwo = velocityOne - velocityTwo
        let delta = finalVelocity(velocityDiff: velocityOneDiffTwo, displacementVector: centerOneToCenterTwoVector)
        let newVelocityOne = velocityOne - delta
        let newVelocityTwo = velocityTwo + delta

        return (newVelocityOne, newVelocityTwo)
    }

    private func finalVelocity(velocityDiff: Vector, displacementVector: Vector) -> Velocity {
        let scale = Vector.dotProduct(
            vectorOne: velocityDiff,
            vectorTwo: displacementVector)
            / (displacementVector.magnitude * displacementVector.magnitude)
        return Velocity.vectorToVelocity(vector: scale * displacementVector)
    }

    /// Get final velocity based on initial velocity
    public func finalVelocity(velocity: Velocity, acceleration: Acceleration, time: Double) -> Velocity {
        let finalX = finalVelocity(
            speed: velocity.xDirection,
            acceleration: acceleration.xDirection,
            time: time)
        let finalY = finalVelocity(
            speed: velocity.yDirection,
            acceleration: acceleration.yDirection,
            time: time)
        return Velocity(xDirection: finalX, yDirection: finalY)
    }

    private func finalVelocity(speed: CGFloat, acceleration: CGFloat, time: Double) -> CGFloat {
        return speed + acceleration * CGFloat(time)
    }

    /// Assumes to be 0 acceleration. 
    public func positionAfterTime(position: CGPoint, velocity: Velocity, time: Double) -> CGPoint {
        let newX = position.x + velocity.xDirection * CGFloat(time)
        let newY = position.y + velocity.yDirection * CGFloat(time)
        return CGPoint(x: newX, y: newY)
    }

    public func getBearing(startPoint: CGPoint, endPoint: CGPoint) -> CGFloat {
        let xLength = endPoint.x - startPoint.x
        let yLength = endPoint.y - startPoint.y
        return atan(-xLength / yLength)
    }
}

extension CGPoint {
    public func displacementTo(point: CGPoint) -> CGFloat {
        let deltaX = self.x - point.x
        let deltaY = self.y - point.y
        return sqrt((deltaX * deltaX) + (deltaY * deltaY))
    }
}
