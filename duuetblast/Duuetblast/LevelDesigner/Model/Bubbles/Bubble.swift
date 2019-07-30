// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A Bubble class containing the bubble type.
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import Foundation

class Bubble {
    var bubbleType: BubbleType

    internal init(bubbleType: BubbleType) {
        self.bubbleType = bubbleType
    }

    public static func getRandomBubble() -> BubbleType {
        guard let randomBubble = BubbleType.getNormalBubbles.randomElement() else {
            fatalError("There must be a bubble in playableBubbles")
        }
        return randomBubble
    }
}
