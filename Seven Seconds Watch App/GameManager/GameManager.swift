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
    private var sparks = Sparks.shared

    init() {
        self.timerBeep = AudioPlayerFactory.createAudioPlayer(fileName: "timer", fileType: "wav")
        self.explodeBeep = AudioPlayerFactory.createAudioPlayer(fileName: "explode", fileType: "wav")
        self.buttonBeep = AudioPlayerFactory.createAudioPlayer(fileName: "button", fileType: "wav")
    }

    func startGame(emitterLayer: CAEmitterLayer?, buttonFrame: CGRect) {
        isGameRunning = true
        currentScore = 0
        timeLeft = 7

        sparks.updateSparks(
            emitterLayer: emitterLayer,
            score: currentScore,
            buttonFrame: buttonFrame,
            isGameRunning: true
        )

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeLeft > 0 {
                self.timeLeft -= 1
                self.timerBeep?.play()
            } else {
                self.timer?.invalidate()
                self.endGame(emitterLayer: emitterLayer, buttonFrame: buttonFrame)
            }
        }
    }

    func endGame(emitterLayer: CAEmitterLayer?, buttonFrame: CGRect) {
        isGameRunning = false
        isGameOver = true
        explodeBeep?.play()

        GameCenterManager.shared.submitScore(with: currentScore)

        sparks.updateSparks(
            emitterLayer: emitterLayer,
            score: currentScore,
            buttonFrame: buttonFrame,
            isGameRunning: false
        )
    }

    func buttonPressed() {
        buttonBeep?.play()
    }

    func resetGame(emitterLayer: CAEmitterLayer?, buttonFrame: CGRect) {
        isGameRunning = false
        isGameOver = false
        timeLeft = 7
        currentScore = 0

        sparks.updateSparks(
            emitterLayer: emitterLayer,
            score: 0,
            buttonFrame: buttonFrame,
            isGameRunning: false
        )
    }
}