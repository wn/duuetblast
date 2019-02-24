// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 GridBubble class to represent a bubble in the grid. 
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import Foundation
import CoreData

class GridBubble: Bubble {
    private let position: Int

    public init(bubbleType: BubbleType, index: Int) {
        position = index
        super.init(bubbleType: bubbleType)
    }

    /// Get next bubble in cycle, used for singleTapForGameBubble gesture.
    public func cycleNextColor() {
        guard let currentBubbleTypeIndex = Bubble.playableBubbles.firstIndex(of: bubbleType) else {
            return
        }
        let index = (currentBubbleTypeIndex + 1) % Bubble.playableBubbles.count
        bubbleType = Bubble.playableBubbles[index]
    }

    /// Get core data object with bubble data
    func savedBubbleData() -> GridBubbleData {
        return GridBubbleData(position: position, bubbleTypeId: bubbleType.getBubbleIndex)
    }

//    /// Set bubble to empty.
//    func eraseBubble() {
//        bubbleType = .empty
//    }
}
