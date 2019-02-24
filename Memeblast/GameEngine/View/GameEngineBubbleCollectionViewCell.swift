//
//  GameEngineBubbleCollectionViewCell.swift
//  LevelDesigner
//
//  Created by Ang Wei Neng on 10/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit

class GameEngineBubbleCollectionViewCell: BubbleCollectionViewCell {
    @IBOutlet private var gameEngineBubble: UIImageView!

    func setImage(imageUrl: String) {
        gameEngineBubble.image = UIImage(named: imageUrl)
    }
}
