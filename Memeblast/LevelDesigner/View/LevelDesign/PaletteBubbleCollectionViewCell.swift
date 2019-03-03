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
        let pos = colorSelectorBubble.frame.origin
        let width = colorSelectorBubble.frame.size.width
        let height = colorSelectorBubble.frame.size.height
        colorSelectorBubble.frame = CGRect(x: pos.x, y: pos.y, width: width, height: height)
        isSelected ? setBubbleSelected() : setBubbleUnselected()
        colorSelectorBubble.layer.backgroundColor = UIColor.white.cgColor
        colorSelectorBubble.layer.cornerRadius = layer.frame.size.height / 2
        colorSelectorBubble.layer.masksToBounds = false
        colorSelectorBubble.clipsToBounds = true
    }

    private func setBubbleSelected() {
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = layer.frame.size.height / 2
        layer.borderWidth = 3
        alpha = 1
    }

    private func setBubbleUnselected() {
        layer.borderColor = nil
        layer.borderWidth = 0
//        layer.cornerRadius = 0
        alpha = 0.6
    }
}
