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
        let image = Constants.cannonBase
        cannonView.image = image
        cannonView.frame.origin.y += cannonBaseHeight * 0.285

        cannonView.animationImages = Constants.cannonAnimationSet
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
}
