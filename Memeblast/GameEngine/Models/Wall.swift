//
//  Wall.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 16/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import CoreGraphics

class Wall: GameObject, Obstacle {
    var wallFrame: CGRect
    var collisionAction: (_ bubble: GameBubble) -> Void
    let stable: Bool

    init(frame: CGRect, stable: Bool, action: @escaping (_ bubble: GameBubble) -> Void) {
        wallFrame = frame
        self.stable = stable
        self.collisionAction = action
        super.init(position: frame.origin)
    }

    internal func didCollide(bubble: GameBubble) -> Bool {
        return wallFrame.intersects(bubble.frame)
    }

    func collideAction(bubble: GameBubble) {
        guard didCollide(bubble: bubble) else {
            return
        }
        collisionAction(bubble)
    }
}
