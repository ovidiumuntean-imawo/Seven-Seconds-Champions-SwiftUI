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
    private let iceCracking: AVAudioPlayer?
    private let explodeBeep: AVAudioPlayer?
    private let buttonBeep: AVAudioPlayer?

    init() {
        self.timerBeep = AudioPlayerFactory.createAudioPlayer(fileName: "timer", fileType: "wav")
        self.iceCracking = AudioPlayerFactory.createAudioPlayer(fileName: "ice-cracking", fileType: "mp3")
        self.explodeBeep = AudioPlayerFactory.createAudioPlayer(fileName: "explode", fileType: "wav")
        self.buttonBeep = AudioPlayerFactory.createAudioPlayer(fileName: "button", fileType: "wav")
    }

    func startGame() {
        isGameRunning = true
        currentScore = 0
        timeLeft = 7
        
        iceCracking?.play()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Verificăm dacă mai avem timp rămas
            if self.timeLeft > 0 {
                // Scădem o secundă la fiecare apel
                self.timeLeft -= 1
                
                // Acum verificăm valoarea NOUĂ a lui timeLeft
                if self.timeLeft == 5 || self.timeLeft == 2 {
                    // Dacă am ajuns la 6 sau 3 secunde, punem sunetul de damage
                } else if self.timeLeft > 0 {
                    // Pentru orice altă valoare mai mare ca 0, punem beep-ul normal
                    self.timerBeep?.play()
                } else {
                    // Dacă timeLeft a ajuns la 0, invalidăm timer-ul și terminăm jocul
                    self.timer?.invalidate()
                    self.endGame()
                }
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
        // buttonBeep?.play()
    }

    func resetGame() {
        isGameRunning = false
        isGameOver = false
        timeLeft = 7
        currentScore = 0
    }
}
