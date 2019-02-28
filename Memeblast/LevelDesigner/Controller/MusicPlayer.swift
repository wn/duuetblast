//
//  Music.swift
//  Memeblast
//
//  Created by Ang Wei Neng on 26/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import Foundation
import AVFoundation

class MusicPlayer {
    var audioPlayer: [AVAudioPlayer] = []

    func playSoundWith(_ filename: String, loop: Int = 0, vol: Float = 1) {
        let audioSourceUrl = Bundle.main.url(forResource: filename, withExtension: Constants.music_ext)
        var playingMusics = audioPlayer.filter { $0.isPlaying }

        guard let audioUrl = audioSourceUrl else {
            print("NO MUSICPATH for \(filename)")
            return
        }
        do {
            let musicPlayer = try AVAudioPlayer.init(contentsOf: audioUrl)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = loop // infinite loop
            musicPlayer.volume = vol
            musicPlayer.play()
            playingMusics.append(musicPlayer)
            audioPlayer = playingMusics
        } catch {
            print("NO MUSIC for \(filename)")
            return
        }
    }
}
