//
//  BubbleThemes.swift
//  Memeblast
//
//  Created by Ang Wei Neng on 28/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

class BubbleThemes {
    let mapTypeToPath: [BubbleType: String]

    init(theme: Theme) {
        switch theme {
        case .standard:
            self.mapTypeToPath = Constants.standardTheme
        }
    }

    func getBubbleTypePath(type: BubbleType) -> String {
        guard let path = mapTypeToPath[type] else {
            return ""
        }
        return path
    }
}

enum Theme {
    case standard
}
