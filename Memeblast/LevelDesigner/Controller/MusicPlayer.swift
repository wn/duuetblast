//
//  Music.swift
//  Memeblast
//
//  Created by Ang Wei Neng on 26/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import Foundation
import AVFoundation

protocol MusicPlayer: class {
    var audioPlayer: [AVAudioPlayer] {get set}
}

extension MusicPlayer {
    func playSoundWith(musics: [AVAudioPlayer], filename: String, loop: Int, vol: Float) -> [AVAudioPlayer] {
        let audioSourceUrl = Bundle.main.url(forResource: filename, withExtension: Constants.music_ext)
        var playingMusics = musics.filter { $0.isPlaying }

        guard let audioUrl = audioSourceUrl else {
            print("NO MUSIC FOUND")
            return []
        }
        do {
            let musicPlayer = try AVAudioPlayer.init(contentsOf: audioUrl)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = loop // infinite loop
            musicPlayer.volume = vol
            musicPlayer.play()
            playingMusics.append(musicPlayer)
            return playingMusics
        } catch {
            print("NO MUSIC for \(filename)")
            return []
        }
    }
}
