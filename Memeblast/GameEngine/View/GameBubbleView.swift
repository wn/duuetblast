//
//  GameBubbleView.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 16/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit

class GameBubbleView {
    var imageView: UIImageView
    var position: CGPoint
    var diameter: CGFloat
    var imageUrl: String

    init(position: CGPoint, imageUrl: String, diameter: CGFloat) {
        self.position = position
        self.diameter = diameter
        self.imageUrl = imageUrl

        let image = UIImage(named: imageUrl)
        imageView = UIImageView(frame: CGRect(x: position.x, y: position.y, width: diameter, height: diameter))
        imageView.image = image
        imageView.transform = CGAffineTransform(rotationAngle: 0)

        rerender()
    }

    func rerender() {
        guard let _ = imageView.superview else {
            return
        }
        let xCoordinate = position.x - radius
        let yCoordinate = position.y - radius
        imageView.frame.origin = CGPoint(x: xCoordinate, y: yCoordinate)
    }

    func fadedBubble() {
        imageView.alpha = 0.7
    }

    var radius: CGFloat {
        return diameter / 2
    }

}
