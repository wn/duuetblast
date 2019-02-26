// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A BubbleType enum containing the different type of
 bubble types.
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

public enum BubbleType: Int, CaseIterable {
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

    var isNormalBubble: Bool {
        switch self {
        case .red, .blue, .green, .orange:
            return true
        default:
            return false
        }
    }

    var isPowerBubble: Bool {
        switch self {
        case .bomb, .lightning, .star:
            return true
        default:
            return false
        }
    }

    static var getNormalBubbles: [BubbleType] {
        return BubbleType.allCases.filter { $0.isNormalBubble }
    }

    static var getPowerBubbles: [BubbleType] {
        return BubbleType.allCases.filter { $0.isPowerBubble }
    }

    static var getAllPaletteBubbles: [BubbleType] {
        return BubbleType.allCases.filter { $0.isNormalBubble || $0.isPowerBubble || $0 == .indestructible }
    }

    static func isPlayableBubble(type: BubbleType) -> Bool {
        return BubbleType.getPowerBubbles.contains(type) || BubbleType.getNormalBubbles.contains(type)
    }
}
