//
//  CannonView.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 16/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit

class CannonView {
    var firingPosition: CGPoint
    var cannonView: UIImageView
    var rotatedAngle: CGFloat = 0

    init(position: CGPoint, superView: UIView) {
        firingPosition = position
        let cannonWidth = Constants.cannonWidth
        let cannonHeight = Constants.cannonHeight
        let topLeftXOfFrame = firingPosition.x - cannonWidth / 2
        let imageFrame = CGRect(x: topLeftXOfFrame, y: superView.frame.height - cannonHeight, width: cannonWidth, height: cannonHeight)
        cannonView = UIImageView(frame: imageFrame)
        renderCannonAndBase(superView: superView)

        firingPosition.y = cannonView.frame.origin.y + cannonView.frame.height * 0.81
    }

    func rotateAngle(_ angle: CGFloat) {
        rotatedAngle = angle
        UIView.animate(withDuration: 0.1) {
            self.cannonView.transform = CGAffineTransform(rotationAngle: angle)
        }
    }

    private func renderCannonAndBase(superView: UIView) {
        // Render base //
        let cannonBaseWidth: CGFloat = 100
        let cannonBaseHeight: CGFloat = 100

        let cannonBaseFrame = CGRect(x: firingPosition.x - cannonBaseWidth / 2, y: superView.frame.height - cannonBaseHeight, width: cannonBaseWidth, height: cannonBaseHeight)
        let cannonBaseView = UIImageView(frame: cannonBaseFrame)
        let cannonBaseImage = UIImage(named: Constants.cannonBaseImage)
        cannonBaseView.image = cannonBaseImage
        superView.addSubview(cannonBaseView)
        superView.bringSubviewToFront(cannonBaseView)

        // Render cannon //
        let image = CannonView.cannonSpriteBase
        cannonView.image = image
        cannonView.frame.origin.y += cannonBaseHeight * 0.285

        cannonView.animationImages = CannonView.cannonSpriteAnimationSet
        cannonView.animationDuration = 0.5
        cannonView.animationRepeatCount = 1

        cannonView.transform = CGAffineTransform(rotationAngle: rotatedAngle)
        superView.addSubview(cannonView)
        superView.sendSubviewToBack(cannonView)

        //cannonView.frame.origin = topLeftOfCannon
        cannonView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.81)
    }

    func animate() {
        self.cannonView.startAnimating()
    }

    static let cannonSpriteRows = 2
    static let cannonSpriteCols = 6
    static let cannonSprite = #imageLiteral(resourceName: "cannon").cgImage!
    static let cannonSpriteWidth = CGFloat(cannonSprite.width) / CGFloat(cannonSpriteCols)
    static let cannonSpriteHeight = CGFloat(cannonSprite.height) / CGFloat(cannonSpriteRows)
    static let cannonSpriteSize = CGSize(width: cannonSpriteWidth,
                                         height: cannonSpriteHeight)
    static let cannonSpriteBase = UIImage(cgImage: cannonSprite.cropping(to:
        CGRect(origin: .zero, size: cannonSpriteSize))!)
    static let cannonSpriteAnimationSet = [
        cannonSpriteBase,
        UIImage(cgImage: cannonSprite.cropping(to:
            CGRect(origin: CGPoint(x: cannonSpriteWidth, y: 0),
                   size: cannonSpriteSize))!),
        UIImage(cgImage: cannonSprite.cropping(to:
            CGRect(origin: CGPoint(x: 2 * cannonSpriteWidth, y: 0),
                   size: cannonSpriteSize))!),
        UIImage(cgImage: cannonSprite.cropping(to:
            CGRect(origin: CGPoint(x: 3 * cannonSpriteWidth, y: 0),
                   size: cannonSpriteSize))!),
        UIImage(cgImage: cannonSprite.cropping(to:
            CGRect(origin: CGPoint(x: 4 * cannonSpriteWidth, y: 0),
                   size: cannonSpriteSize))!),
        UIImage(cgImage: cannonSprite.cropping(to:
            CGRect(origin: CGPoint(x: 5 * cannonSpriteWidth, y: 0),
                   size: cannonSpriteSize))!),
        UIImage(cgImage: cannonSprite.cropping(to:
            CGRect(origin: CGPoint(x: 0, y: cannonSpriteHeight),
                   size: cannonSpriteSize))!),
        UIImage(cgImage: cannonSprite.cropping(to:
            CGRect(origin: CGPoint(x: cannonSpriteWidth, y: cannonSpriteHeight),
                   size: cannonSpriteSize))!),
        UIImage(cgImage: cannonSprite.cropping(to:
            CGRect(origin: CGPoint(x: 2 * cannonSpriteWidth, y: cannonSpriteHeight),
                   size: cannonSpriteSize))!),
        UIImage(cgImage: cannonSprite.cropping(to:
            CGRect(origin: CGPoint(x: 3 * cannonSpriteWidth, y: cannonSpriteHeight),
                   size: cannonSpriteSize))!),
        UIImage(cgImage: cannonSprite.cropping(to:
            CGRect(origin: CGPoint(x: 4 * cannonSpriteWidth, y: cannonSpriteHeight),
                   size: cannonSpriteSize))!),
        UIImage(cgImage: cannonSprite.cropping(to:
            CGRect(origin: CGPoint(x: 5 * cannonSpriteWidth, y: cannonSpriteHeight),
                   size: cannonSpriteSize))!),
        ]
}
