// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A palette bubble cell used to represent a palette bubble UI cell.
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import UIKit

class PaletteBubbleCollectionViewCell: BubbleCollectionViewCell {
    @IBOutlet private var colorSelectorBubble: UIImageView!

    func setupImage(imageUrl: String, isSelected: Bool) {
        colorSelectorBubble.image = UIImage(named: imageUrl)
        isSelected ? setBubbleSelected() : setBubbleUnselected()
    }

    private func setBubbleSelected() {
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = frame.size.width / 2
        layer.borderWidth = 3
        alpha = 1
    }

    private func setBubbleUnselected() {
        layer.borderColor = nil
        layer.borderWidth = 0
        layer.cornerRadius = 0
        alpha = 0.5
    }
}
