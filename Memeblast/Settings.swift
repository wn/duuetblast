//
//  Settings.swift
//  Memeblast
//
//  Created by Ang Wei Neng on 28/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import AVFoundation

class Settings {
    static var isMusicOn = true
    static var selectedTheme = BubbleThemes.init(theme: .standard)
    static var musicPlayer = MusicPlayer()

    static func playSoundWith(_ filename: String, loop: Int = 0, vol: Float = 1) {
        musicPlayer.playSoundWith(filename, loop: loop, vol: vol)
    }
}
