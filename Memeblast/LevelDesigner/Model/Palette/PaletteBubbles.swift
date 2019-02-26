// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 Palette bubbles in the palette.
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import Foundation

class PaletteBubbles {
    private var paletteBubbles: [PaletteBubble] = []

    public init() {
        for color in BubbleType.getNormalBubbles {
            paletteBubbles.append(PaletteBubble(bubbleType: color))
        }
        for color in BubbleType.getSpecialBubbles {
            paletteBubbles.append(PaletteBubble(bubbleType: color))
        }
        // Add erase button to palette
        paletteBubbles.append(PaletteBubble(bubbleType: .erase))
    }

    public var count: Int {
        return paletteBubbles.count
    }

    /// Return the bubble at the provided index.
    public func getBubbleAtIndex(index: Int) -> PaletteBubble {
        return paletteBubbles[index]
    }

    /// Retrieve the bubble that is currently selected.
    func getCurrentlySelectedPaletteType() -> BubbleType? {
        let isSelectedPalettes = paletteBubbles.filter { $0.isSelected }
        precondition(isSelectedPalettes.count <= 1)
        if isSelectedPalettes.isEmpty {
            return nil
        }
        // If in erase mode, return empty bubble instead
        let currentType = isSelectedPalettes[0].bubbleType
        if currentType == .erase {
            return .empty
        }
        return currentType
    }

    /// Set bubble in index to be selected and
    /// set bubble not in index to be unselected.
    func togglePaletteBubble(index: Int) {
        if paletteBubbles[index].isSelected {
            paletteBubbles[index].isSelected = !paletteBubbles[index].isSelected
            return
        }
        for bubbleIndex in 0..<paletteBubbles.count {
            paletteBubbles[bubbleIndex].isSelected = bubbleIndex == index
        }
    }
}
