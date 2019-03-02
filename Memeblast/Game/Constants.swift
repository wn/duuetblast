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
    // TODO: Dark theme and light theme
    static let background = "background-hill.png"

    // MARK: - Music
    static let music_ext = ".mp3"
    static let background_music = "maplestoryx" // TODO: remove x
    static let zap_sound = "zap_sound"
    static let bomb_sound = "bomb_sound"
    static let falling_sound = "falling"
    static let start_game_sound = "start_sound"
    static let bubble_drop_sound = "bubble_drop_to_collection"
    static let gameover_sound = "gameover_sound"
    static let firing_sound = "cannon_sound"
    static let bounce_wall = "bounce"
    static let chainsaw_sound = "chainsaw_sound"
    // TODO: 2 ball colliding sound
    // winning sound
    // Drop to collection sound
    /// Settings.playSoundWith(Constants.gameover_sound)

    static let cannon_base_image = "cannon-base.png"

    // MARK: - Themes
    static let standardTheme: [BubbleType: String] = [
        .red: "bubble-red.png",
        .blue: "bubble-blue.png",
        .orange: "bubble-orange.png",
        .green: "bubble-green.png",
        .empty: "bubble-grey.png",
        .erase: "erase.png",
        .bomb: "bubble-bomb.png",
        .indestructible: "bubble-indestructible.png",
        .star: "bubble-star.png",
        .lightning: "bubble-lightning.png",
        .invisible: "bubble-transluent_white.png",
        .chainsaw_bubble: "bubble-chainsaw.png",
        .magnet: "bubble-magnet.png",
        .rocket: "bubble-rocket.png",
        .random: "bubble-random.png",
        .bin: "bubble-bin.png",
    ]

    // MARK: - Gameplay scoring
    static let initialScore = 10000
    static let unattachedBubble = 293
    static let firingBubble = -300
    static let matchBubble = 373
    static let binBubble = 524
    static let starBubble = 337
    static let bombScore = 412
    static let lightningScore = 237
    static let rocketScore = 282

    // MARK: Gameplay time
    static let randomBubbleInterval: Double = 10
    // Used when instantiating new level and timestepper isnt rendered yet.
    static let defaultTime = 100
}
