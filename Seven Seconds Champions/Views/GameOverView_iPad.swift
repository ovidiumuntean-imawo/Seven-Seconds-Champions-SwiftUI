//
//  GameOverView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//

import SwiftUI
import AVFoundation
import GameKit
import StoreKit

// MARK: - GameOverView_iPad
struct GameOverView_iPad: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var gameManager: GameManager
    
    @Binding var previousScore: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) var requestReview
    
    var body: some View {
        Group {
            if let challengeOutcome = gameManager.challengeOutcome, let target = gameManager.challengeTarget {
                // Dacă a fost o provocare, afișăm ecranul de rezultat
                ChallengeResultView_iPad(challengeOutcome: challengeOutcome, yourScore: gameManager.currentScore, targetScore: target)
            } else {
                // Altfel, afișăm ecranul normal de Game Over
                NormalGameOverView_iPad(gameManager: gameManager, previousScore: $previousScore)
            }
        }
        .fontDesign(.rounded)
        .onAppear {
            appState.challengeScoreToBeat = nil
        }
        .onChange(of: appState.newChallengeReceived) {
            print("Provocare nouă primită în timp ce GameOver era deschis. Se închide...")
            dismiss()
        }
    }
}

struct NormalGameOverView_iPad: View {
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
        let redirectPageURL = "https://ovidiumuntean-imawo.github.io/7seconds-challenge-redirect/redirect.html"
        
        let finalURL = "\(redirectPageURL)?score=\(gameManager.currentScore)"
        
        return "I challenge you to 7 Seconds! I scored \(gameManager.currentScore) taps. Can you beat that? \(finalURL)"
    }
    
    var body: some View {
        ZStack {
            // Background
            RotatingBackground(isAnimating: isAnimationActive)
                .ignoresSafeArea()
            
            ParticleView(isActive: $areParticlesActive)
                            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("Game Over")
                    .font(.system(size: 128, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1)) {
                            scale = 1.0
                        }
                    }
                    /*.onAppear {
                        withAnimation(.easeInOut(duration: 1), {
                            scale = 1.6
                        })
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.easeInOut(duration: 1)) {
                                scale = 1.0
                            }
                        }
                    }*/
                
                Text("YOU SCORED")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                
                Text("\(gameManager.currentScore)")
                    .font(.system(size: 128, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.top, -24)
                    .scaleEffect(scaleScore)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1)) {
                            scaleScore = 1.0
                        }
                    }
                
                Text("TAPS")
                    .font(.system(size: 36, weight: .medium))
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
                        .font(.system(size: 24, weight: .medium))
                        .frame(width: 320)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                
                ShareLink(item: challengeText) {
                    Label("Challenge Your Friends!", systemImage: "gamecontroller.fill")
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 320)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                Text("Others tried too!")
                    .font(.system(size: 36, weight: .medium))
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
                        .font(.system(size: 24, weight: .medium))
                        .frame(width: 320)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.top, -16)
                
                Spacer()
            }
            .padding()
        }
        .fontDesign(.rounded)
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
        /*.alert(
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
                previousScore = gameManager.currentScore
                isAnimationActive = false
                
                if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                    GameCenterManager.shared.showLeaderboard(from: rootVC)
                }
            }
        } message: { message in
            Text("\n\(message)\n")
                .multilineTextAlignment(.center)
                .padding()

        }*/
    }
}

struct ChallengeResultView_iPad: View {
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
                    .font(.system(size: 148))
                    .foregroundColor(challengeOutcome == .win ? .green : .red)
                
                Text("Challenge")
                    .font(.system(size: 128, weight: .heavy))
                    .foregroundColor(.white)
                
                Text(challengeOutcome == .win ? "WON!" : "LOST")
                    .font(.system(size: 96, weight: .thin))
                    .foregroundColor(.white)
                
                Text("Your score: \(yourScore)")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
                
                Text("Target: \(targetScore)")
                    .font(.system(size: 48, weight: .regular))
                    .foregroundColor(.yellow)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Back to Game")
                        .font(.system(size: 24, weight: .medium))
                        .frame(width: 320)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding()
        }
        .fontDesign(.rounded)
    }
}

#Preview("Game Over Normal") {
    let manager = GameManager()
    manager.currentScore = 75
    
    return NormalGameOverView_iPad(gameManager: manager, previousScore: .constant(70))
}

#Preview("Challenge WON") {
    let manager = GameManager()
    manager.currentScore = 60
    
    return ChallengeResultView_iPad(challengeOutcome: .win, yourScore: manager.currentScore, targetScore: 50)
}

#Preview("Challenge LOST") {
    let manager = GameManager()
    manager.currentScore = 45
    
    return ChallengeResultView_iPad(challengeOutcome: .loss, yourScore: manager.currentScore, targetScore: 50)
}

#Preview("Game Over with High Score") {
    let manager = GameManager()
    manager.currentScore = 90
    manager.isNewHighScore = true
    
    return NormalGameOverView_iPad(gameManager: manager, previousScore: .constant(85))
}
