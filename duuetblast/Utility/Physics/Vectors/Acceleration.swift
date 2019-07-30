//
//  Acceleration.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 17/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import CoreGraphics

public class Acceleraxtion: Vector {
    // Vector addition:
    public static func += ( left: inout Acceleration, right: Acceleration) {
        left = Acceleration(
            xDirection: left.xDirection + right.xDirection,
            yDirection: left.yDirection + right.yDirection)
    }

    public static var gravity: Acceleration {
        return Acceleration(magnitude: 1_000, angle: CGFloat.pi)
    }
}
