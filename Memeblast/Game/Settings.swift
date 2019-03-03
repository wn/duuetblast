//
//  Settings.swift
//  Memeblast
//
//  Created by Ang Wei Neng on 28/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import AVFoundation
import UIKit

class Settings {
    static var isMusicOn = true
    static var selectedTheme = BubbleThemes(theme: .standard)
    static var musicPlayer = MusicPlayer()

    static func playSoundWith(_ filename: String, loop: Int = 0, vol: Float = 1) {
        musicPlayer.playSoundWith(filename, loop: loop, vol: vol)
    }

    /// Function to load background
    static func loadBackground(view: UIView) {
        let gameViewHeight = view.frame.size.height
        let gameViewWidth = view.frame.size.width
        let backgroundImage = UIImage(named: Constants.background)
        let background = UIImageView(image: backgroundImage)
        background.frame = CGRect(x: 0, y: 0, width: gameViewWidth, height: gameViewHeight)
        view.addSubview(background)
        view.sendSubviewToBack(background)
    }
}
