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

    init(position: CGPoint, imageURL: String, diameter: CGFloat) {
        self.position = position
        self.diameter = diameter

        let image = UIImage(named: imageURL)
        imageView = UIImageView(frame: CGRect(x: position.x, y: position.y, width: diameter, height: diameter))
        imageView.image = image

        rerender()
    }

    func rerender() {
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
