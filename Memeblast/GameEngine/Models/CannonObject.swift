//
//  CannonObject.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 15/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//
import CoreGraphics
import AVFoundation

public class CannonObject: GameObject {

    var firingBubble: GameBubble?
    var angle: CGFloat = 0
    private weak var delegate: GameEngine?

    private static let firingVelocity: CGFloat = 1500

    override init(position: CGPoint) {
        super.init(position: position)
    }

    func setDelegate(gameEngine: GameEngine) {
        delegate = gameEngine
    }

    func fireBubble() {
        guard let bubbleToFire = firingBubble else {
            return
        }

        bubbleToFire.setVelocity(speed: CannonObject.firingVelocity, angle: angle)
        firingBubble = nil
        delegate?.movingFiringBubble(bubbleToFire)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.delegate?.generateFiringBubble(cannon: self)
        }
    }

    func loadBubble(_ bubble: GameBubble) {
        firingBubble = bubble
    }

    func setAngle(_ angle: CGFloat) {
        self.angle = angle
    }
}
