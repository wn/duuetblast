// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A Bubble class containing the bubble type.
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import Foundation

class Bubble {
    var bubbleType: BubbleType

    /// List of all bubbles that is part of the game.
    public static let playableBubbles: [BubbleType] = [.red, .blue, .orange, .green]
    public static let specialBubbles: [BubbleType] = [.indestructible, .lightning, .bomb, .star]

    internal init(bubbleType: BubbleType) {
        self.bubbleType = bubbleType
    }

    /// Image url to retrieve image of bubble.
    public var imageUrl: String {
        return bubbleType.imageUrl
    }

    public static func getRandomBubble() -> BubbleType {
        guard let randomBubble = Bubble.playableBubbles.randomElement() else {
            fatalError("There must be a bubble in playableBubbles")
        }
        return randomBubble
    }
}
