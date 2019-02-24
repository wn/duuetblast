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
    var imageView: UIImageView
    var rotatedAngle: CGFloat

    init(position: CGPoint, superView: UIView) {
        self.firingPosition = position
        //let image = UIImage(named: "cannon.png")
        let image = CannonView.cannonSpriteBase
        let imageFrame = CGRect(x: 0, y: 0, width: CannonView.cannonSpriteWidth, height: CannonView.cannonSpriteHeight)
        imageView = UIImageView(frame: imageFrame)
        imageView.image = image

        imageView.animationImages = CannonView.cannonSpriteAnimationSet
        imageView.animationRepeatCount = 1

        rotatedAngle = 0
        imageView.transform = CGAffineTransform(rotationAngle: rotatedAngle)
        superView.addSubview(imageView)
        render()
    }

    func rotateAngle(_ angle: CGFloat) {
        rotatedAngle = angle
        UIView.animate(withDuration: 0.1) {
            self.imageView.transform = CGAffineTransform(rotationAngle: angle)
        }
    }

    func render() {
        imageView.frame.origin = topLeftOfCannon
    }

    var topLeftOfCannon: CGPoint {
        let xCoordinate = firingPosition.x - CannonView.cannonSpriteWidth / 2
        let yCoordinate = firingPosition.y - CannonView.cannonSpriteHeight / 2
        return CGPoint(x: xCoordinate, y: yCoordinate)
    }

    static let cannonSpriteRows = 2
    static let cannonSpriteCols = 6
    static let cannonSprite = #imageLiteral(resourceName: "cannon").cgImage!
    static let cannonSpriteWidth = CGFloat(cannonSprite.width / cannonSpriteCols)
    static let cannonSpriteHeight = CGFloat(cannonSprite.height / cannonSpriteRows)
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
