//
//  AudioPlayerFactory.swift
//  seven.seconds
//
//  Created by Ovidiu Muntean on 05.09.2023.
//

import UIKit
import AVFoundation
import GameKit

class AudioPlayerFactory {
    static func createAudioPlayer(fileName: String, fileType: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("Failed to locate \(fileName).\(fileType)")
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            print("Failed to initialize AVAudioPlayer: \(error.localizedDescription)")
            return nil
        }
    }
}

