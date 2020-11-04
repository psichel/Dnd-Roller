//
//  PlaySound.swift
//  DnD Roller
//
//  Created by Peter Sichel on 11/2/20.
//

import Foundation
import AVFoundation

class MyAudio {

    var audioPlayer = AVAudioPlayer()

    func playSound(name: String) {
        let urlPath = Bundle.main.url(forResource:name, withExtension: "mp3")
        guard let soundURL = urlPath else {
            print("Did not find sound resource: \(name)")
            return
        }
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.play()
        }catch {
            print("Error attempting to play sound: \(error)")
        }
    }

}
