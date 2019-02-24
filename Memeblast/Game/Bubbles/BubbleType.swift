// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A BubbleType enum containing the different type of
 bubble types.
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

public enum BubbleType: Int {
    case red = 0
    case blue = 1
    case orange = 2
    case green = 3
    case empty = 4
    case bomb = 5
    case indestructible = 6
    case star = 7
    case lightning = 8
    case erase = 9
    case invisible = 10

    var getBubbleIndex: Int {
        return self.rawValue
    }

    static func getBubbleType(bubbleTypeIndex: Int) -> BubbleType {
        guard let bubbleType = BubbleType(rawValue: bubbleTypeIndex) else {
            fatalError("Shouldn't be requesting bubble that does not exist.")
        }
        return bubbleType
    }

    var imageUrl: String {
        switch self {
        case .red:
            return "bubble-red.png"
        case .blue:
            return "bubble-blue.png"
        case .orange:
            return "bubble-orange.png"
        case .green:
            return "bubble-green.png"
        case .empty:
            return "bubble-grey.png"
        case .erase:
            return "erase.png"
        case .bomb:
            return "bubble-bomb.png"
        case .indestructible:
            return "bubble-indestructible.png"
        case .star:
            return "bubble-star.png"
        case .lightning:
            return "bubble-lightning.png"
        case .invisible:
            return "bubble-transluent_white.png"
        }
    }
}
