//
//  GameObject.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 10/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//
import Foundation
import CoreGraphics

public class GameObject {
    var position: CGPoint
    let uniqueId = UUID()

    init(position: CGPoint) {
        self.position = position
    }
}

extension GameObject: Hashable {
    public static func == (lhs: GameObject, rhs: GameObject) -> Bool {
        return lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueId)
    }
}

protocol Obstacle {
    func didCollide(bubble: GameBubble) -> Bool
    func collideAction(bubble: GameBubble)
    var stable: Bool { get }
}
