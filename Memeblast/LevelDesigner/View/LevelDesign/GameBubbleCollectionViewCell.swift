// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A Game Bubble Cell used to represent a game bubble in the grid. 
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import UIKit

class GameBubbleCollectionViewCell: BubbleCollectionViewCell {
    @IBOutlet private var gameBubble: UIImageView!

    func setImage(imageUrl: String) {
        gameBubble.image = UIImage(named: imageUrl)
    }
}
