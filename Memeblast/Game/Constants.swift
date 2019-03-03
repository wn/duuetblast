//
//  Constants.swift
//  Memeblast
//
//  Created by Ang Wei Neng on 26/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit

class Constants {
    static let cannonHeight: CGFloat = 200
    static let cannonWidth: CGFloat = 100

    static let numOfRows = 9
    static let numOfCols = 12

    // MARK: - Background
    static let background = "background-hill.png"

    // MARK: - Music
    static let musicExt = ".mp3"
    static let backgroundMusic = "maplestoryx" // TODO: remove x
    static let zapSound = "zap_sound"
    static let bombSound = "bomb_sound"
    static let fallingSound = "falling"
    static let startGameSound = "start_sound"
    static let bubbleDropSound = "bubble_drop_to_collection"
    static let gameoverSound = "gameover_sound"
    static let firingSound = "cannon_sound"
    static let bounceWall = "bounce"
    static let chainsawSound = "chainsaw_sound"
    // TODO: 2 ball colliding sound
    // winning sound
    // Drop to collection sound
    /// Settings.playSoundWith(Constants.gameover_sound)

    static let cannonBaseImage = "cannon-base.png"

    // MARK: - Themes
    static let standardTheme: [BubbleType: String] = [
        .red: "bubble-red.png",
        .blue: "bubble-blue.png",
        .orange: "bubble-orange.png",
        .green: "bubble-green.png",
        .empty: "bubble-empty.png",
        .erase: "erase.png",
        .bomb: "bubble-bomb.png",
        .indestructible: "bubble-indestructible.png",
        .star: "bubble-star.png",
        .lightning: "bubble-lightning.png",
        .invisible: "bubble-transluent_white.png",
        .chainsawBubble: "bubble-chainsaw.png",
        .magnet: "bubble-magnet.png",
        .rocket: "bubble-rocket.png",
        .random: "bubble-random.png",
        .bin: "bubble-bin.png",
    ]

    // MARK: - Gameplay scoring
    static let initialScore = 10_000
    static let extraTimePoints = 151
    static let unattachedBubblePoints = 293
    static let firingBubblePoints = -300
    static let matchBubblePoints = 373
    static let binBubblePoints = 524
    static let starBubblePoints = 337
    static let bombPoints = 412
    static let lightningPoints = 237
    static let rocketPoints = 282

    // MARK: Gameplay time
    static let randomBubbleInterval: Double = 10
    // Used when instantiating new level and timestepper isnt rendered yet.
    static let defaultTime = 100
}
