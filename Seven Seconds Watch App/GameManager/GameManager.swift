//
//  GameManager.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 15.01.2025.
//


import SwiftUI
import AVFoundation
import GameKit

class GameManager: ObservableObject {
    @Published var timeLeft: Int = 7
    @Published var currentScore: Int = 0
    @Published var previousScore: Int = 0
    @Published var isGameRunning: Bool = false
    @Published var isGameOver: Bool = false

    private var timer: Timer?
    private let timerBeep: AVAudioPlayer?
    private let explodeBeep: AVAudioPlayer?
    private let buttonBeep: AVAudioPlayer?

    init() {
        self.timerBeep = AudioPlayerFactory.createAudioPlayer(fileName: "timer", fileType: "wav")
        self.explodeBeep = AudioPlayerFactory.createAudioPlayer(fileName: "explode", fileType: "wav")
        self.buttonBeep = AudioPlayerFactory.createAudioPlayer(fileName: "button", fileType: "wav")
    }

    func startGame() {
        isGameRunning = true
        currentScore = 0
        timeLeft = 7

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeLeft > 0 {
                self.timeLeft -= 1
                self.timerBeep?.play()
            } else {
                self.timer?.invalidate()
                self.endGame()
            }
        }
    }

    func endGame() {
        isGameRunning = false
        isGameOver = true
        explodeBeep?.play()

        if currentScore < 145 {
            GameCenterManager.shared.submitScore(with: currentScore)
        }
        
        AchievementManager.shared.handleAchievements(for: currentScore)
    }

    func buttonPressed() {
        buttonBeep?.play()
    }

    func resetGame() {
        isGameRunning = false
        isGameOver = false
        timeLeft = 7
        currentScore = 0
    }
}
