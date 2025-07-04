//
//  GameOverView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 15.01.2025.
//

import SwiftUI
import AVFoundation
import GameKit
import StoreKit

// MARK: - GameOverView_iPhone
struct GameOverView_iPhone: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var gameManager: GameManager
    
    @Binding var previousScore: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) var requestReview
    
    var body: some View {
        Group {
            if let challengeOutcome = gameManager.challengeOutcome, let target = gameManager.challengeTarget {
                // Dacă a fost o provocare, afișăm ecranul de rezultat
                ChallengeResultView(challengeOutcome: challengeOutcome, yourScore: gameManager.currentScore, targetScore: target)
            } else {
                // Altfel, afișăm ecranul normal de Game Over
                NormalGameOverView(gameManager: gameManager, previousScore: $previousScore)
            }
        }
        .onAppear {
            appState.challengeScoreToBeat = nil
        }
        .onChange(of: appState.newChallengeReceived) {
            print("Provocare nouă primită în timp ce GameOver era deschis. Se închide...")
            dismiss()
        }
    }
}

struct NormalGameOverView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var gameManager: GameManager
    
    @Binding var previousScore: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) var requestReview
    
    @State private var showAchievementAlert = false
    @State private var showNewHighScoreAlert = false
    
    // Particles
    @State private var areParticlesActive: Bool = false
    @State private var emitterLayer: CAEmitterLayer?
    @State private var emitterCell = CAEmitterCell()
    
    @State private var scale: CGFloat = 3.0
    @State private var scaleScore: CGFloat = 0
    @State private var rotation: Double = 0
    
    @State private var isAnimationActive: Bool = false
    
    private var challengeText: String {
        let gameURL = "sevenseconds://challenge?score=\(gameManager.currentScore)"
        return "I challenge you to 7 Seconds! I scored \(gameManager.currentScore) taps. Can you beat that? \(gameURL)"
    }
    
    var body: some View {
        ZStack {
            // Background
            RotatingBackground(isAnimating: isAnimationActive)
                .ignoresSafeArea()
            
            ParticleView(isActive: $areParticlesActive)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Game Over")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1)) {
                            scale = 1.0
                        }
                    }
                
                Text("YOU SCORED")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                
                Text("\(gameManager.currentScore)")
                    .font(.system(size: 72, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.top, -24)
                    .scaleEffect(scaleScore)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1)) {
                            scaleScore = 1.0
                        }
                    }
                
                Text("TAPS")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.top, -24)
                
                Button(action: {
                    previousScore = gameManager.currentScore
                    isAnimationActive = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        dismiss()
                    }
                }) {
                    Text("Play again")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 32)
                
                ShareLink(item: challengeText) {
                    Label("Challenge Your Friends!", systemImage: "gamecontroller.fill")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                Text("Others tried too!")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                Button(action: {
                    previousScore = gameManager.currentScore
                    isAnimationActive = false
                    
                    if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                        GameCenterManager.shared.showLeaderboard(from: rootVC)
                    }
                }) {
                    Text("View high scores")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 32)
                .padding(.top, -16)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            // Create small background sparks
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                areParticlesActive = true
            }
            
            if gameManager.isNewHighScore {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showNewHighScoreAlert = true
                }
            } else if let achievement = gameManager.achievementMessage, gameManager.currentScore >= 35 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showAchievementAlert = true
                }
            }
        }
        .onDisappear {
            areParticlesActive = false
        }
        .alert(isPresented: $showNewHighScoreAlert) {
            Alert(
                title: Text("PHENOMENAL! 🚀"),
                message: Text("Congrats, you’ve just set a new record: \(gameManager.currentScore) taps! \n\nYou're a legend — part human, part lightning! ⚡️"),
                dismissButton: .default(Text("Thanks!"), action: {
                    requestReview()
                })
            )
        }
        .alert(
            "Achievement Unlocked!",
            isPresented: $showAchievementAlert,
            presenting: gameManager.achievementMessage
        ) { message in
            Button("Back to game", role: .cancel) {
                previousScore = gameManager.currentScore
            }
            Button("Show My Achievements") {
                previousScore = gameManager.currentScore
                isAnimationActive = false
                
                if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                    GameCenterManager.shared.showAchievements(from: rootVC)
                }
            }
            Button("View High Scores") {
                isAnimationActive = false
                previousScore = gameManager.currentScore
                
                if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                    GameCenterManager.shared.showLeaderboard(from: rootVC)
                }
            }
        } message: { message in
            Text("\n\(message)\n")
                .multilineTextAlignment(.center)
                .padding()

        }
    }
}

struct ChallengeResultView: View {
    @Environment(\.dismiss) private var dismiss
    var challengeOutcome: ChallengeOutcome
    var yourScore: Int
    var targetScore: Int
    
    var body: some View {
        ZStack {
            RotatingBackground(isAnimating: true)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: challengeOutcome == .win ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 96))
                    .foregroundColor(challengeOutcome == .win ? .green : .red)
                
                Text("Challenge")
                    .font(.system(size: 64, weight: .heavy))
                    .foregroundColor(.white)
                
                Text(challengeOutcome == .win ? "WON!" : "LOST")
                    .font(.system(size: 48, weight: .thin))
                    .foregroundColor(.white)
                
                Text("Your score: \(yourScore)")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
                
                Text("Target: \(targetScore)")
                    .font(.system(size: 36, weight: .regular))
                    .foregroundColor(.yellow)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Back to Game")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview("Game Over Normal") {
    let manager = GameManager()
    manager.currentScore = 75
    
    return NormalGameOverView(gameManager: manager, previousScore: .constant(70))
}

#Preview("Challenge WON") {
    let manager = GameManager()
    manager.currentScore = 60
    
    return ChallengeResultView(challengeOutcome: .win, yourScore: manager.currentScore, targetScore: 50)
}

#Preview("Challenge LOST") {
    let manager = GameManager()
    manager.currentScore = 45
    
    return ChallengeResultView(challengeOutcome: .loss, yourScore: manager.currentScore, targetScore: 50)
}

#Preview("Game Over with High Score") {
    let manager = GameManager()
    manager.currentScore = 90
    manager.isNewHighScore = true
    
    return NormalGameOverView(gameManager: manager, previousScore: .constant(85))
}
