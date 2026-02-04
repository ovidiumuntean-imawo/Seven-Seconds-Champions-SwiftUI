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
                // Dacă a fost o provocare
                ChallengeResultView(challengeOutcome: challengeOutcome, yourScore: gameManager.currentScore, targetScore: target)
            } else {
                // Game Over Normal
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

// MARK: - ECRAN NORMAL GAME OVER
struct NormalGameOverView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var gameManager: GameManager
    
    @Binding var previousScore: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) var requestReview
    
    @State private var showNewHighScoreAlert = false
    @State private var showAchievementAlert = false // Păstrat logic, dar nefolosit vizual momentan
    
    // Particles
    @State private var areParticlesActive: Bool = false
    
    // Animations
    @State private var scaleTitle: CGFloat = 0.5
    @State private var opacityTitle: Double = 0
    @State private var scoreScale: CGFloat = 0.8
    @State private var buttonOffset: CGFloat = 50
    @State private var buttonOpacity: Double = 0
    
    private var challengeText: String {
        let redirectPageURL = "https://ovidiumuntean-imawo.github.io/7seconds-challenge-redirect/redirect.html"
        let finalURL = "\(redirectPageURL)?score=\(gameManager.currentScore)"
        return "I challenge you to 7 Seconds! I scored \(gameManager.currentScore) taps. Can you beat that? \(finalURL)"
    }
    
    var body: some View {
        ZStack {
            // 1. FUNDAL (Același ca în GameView)
            NormalBackground()
                .ignoresSafeArea()
            
            // 2. PARTICULE
            ParticleView(isActive: $areParticlesActive)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // --- TITLU ---
                Text("GAME OVER")
                    .font(.system(size: 52, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .shadow(color: .neonRed, radius: 10, x: 0, y: 0)
                    .shadow(color: .neonRed.opacity(0.5), radius: 20, x: 0, y: 0)
                    .scaleEffect(scaleTitle)
                    .opacity(opacityTitle)
                
                Spacer().frame(height: 40)
                
                // --- SCOR ---
                VStack(spacing: 10) {
                    Text("YOU SCORED")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .tracking(4)
                        .foregroundColor(.neonCyan.opacity(0.7))
                    
                    ZStack {
                        // Glow spate
                        Circle()
                            .fill(RadialGradient(colors: [.neonBlue.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 100))
                            .frame(width: 200, height: 80)
                        
                        Text("\(gameManager.currentScore)")
                            .font(.system(size: 90, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .neonCyan, radius: 10)
                            .scaleEffect(scoreScale)
                    }
                    
                    Text("TAPS")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                // --- BUTOANE ---
                VStack(spacing: 20) {
                    // 1. PLAY AGAIN (Cel mai important)
                    Button(action: {
                        restartGame()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("RETRY MISSION")
                        }
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.neonCyan.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.neonCyan, lineWidth: 2)
                                .shadow(color: .neonCyan, radius: 5)
                        )
                    }
                    
                    // 2. CHALLENGE FRIEND
                    ShareLink(item: challengeText) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("CHALLENGE FRIEND")
                        }
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.neonPurple.opacity(0.15))
                        .foregroundColor(.neonPurple)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.neonPurple.opacity(0.5), lineWidth: 1)
                        )
                    }
                    
                    // 3. LEADERBOARD
                    HStack(spacing: 15) {
                        Button(action: {
                            openLeaderboard()
                        }) {
                            VStack {
                                Image(systemName: "trophy.fill")
                                    .font(.title2)
                                Text("RANKS")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.05))
                            .foregroundColor(.yellow)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.yellow.opacity(0.3), lineWidth: 1))
                        }
                        
                        // BUTON DE HOME / EXIT (Opțional, dacă vrei să ieși de tot)
                         /*Button(action: {
                             // Dismiss total
                         }) {
                             VStack {
                                 Image(systemName: "house.fill")
                                     .font(.title2)
                                 Text("HOME")
                                     .font(.caption)
                                     .fontWeight(.bold)
                             }
                             .frame(maxWidth: .infinity)
                             .padding(.vertical, 12)
                             .background(Color.white.opacity(0.05))
                             .foregroundColor(.white)
                             .cornerRadius(12)
                             .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.3), lineWidth: 1))
                         }*/
                    }
                }
                .padding(.horizontal, 40)
                .offset(y: buttonOffset)
                .opacity(buttonOpacity)
                
                Spacer().frame(height: 50)
            }
        }
        .onAppear {
            animateEntrance()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                areParticlesActive = true
            }
            
            if gameManager.isNewHighScore {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showNewHighScoreAlert = true
                }
            }
        }
        .onDisappear {
            areParticlesActive = false
        }
        .alert(isPresented: $showNewHighScoreAlert) {
            Alert(
                title: Text("NEW RECORD! 🚀"),
                message: Text("UNBELIEVABLE!\nYou hit \(gameManager.currentScore) taps.\nYou are officially a LEGEND."),
                dismissButton: .default(Text("Let's Go!"), action: {
                    requestReview()
                })
            )
        }
    }
    
    // --- Helper Functions ---
    
    private func restartGame() {
        previousScore = gameManager.currentScore
        // Micul delay pentru animație de ieșire dacă vrei, sau direct:
        dismiss()
    }
    
    private func openLeaderboard() {
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            GameCenterManager.shared.showLeaderboard(from: rootVC)
        }
    }
    
    private func animateEntrance() {
        // 1. Titlul cade greu
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scaleTitle = 1.0
            opacityTitle = 1.0
        }
        
        // 2. Scorul face pop
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.2)) {
            scoreScale = 1.0
        }
        
        // 3. Butoanele urcă
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            buttonOffset = 0
            buttonOpacity = 1.0
        }
    }
}

// MARK: - CHALLENGE RESULT (WIN/LOSS)
struct ChallengeResultView: View {
    @Environment(\.dismiss) private var dismiss
    var challengeOutcome: ChallengeOutcome
    var yourScore: Int
    var targetScore: Int
    
    @State private var scaleEffect: CGFloat = 0.5
    @State private var opacityEffect: Double = 0
    
    var isWin: Bool {
        return challengeOutcome == .win
    }
    
    var body: some View {
        ZStack {
            NormalBackground().ignoresSafeArea()
            
            VStack(spacing: 25) {
                Spacer()
                
                // ICON
                Image(systemName: isWin ? "trophy.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(isWin ? .green : .red)
                    .shadow(color: isWin ? .green : .red, radius: 20)
                    .scaleEffect(scaleEffect)
                
                // TEXT STATUS
                Text(isWin ? "MISSION\nACCOMPLISHED" : "MISSION\nFAILED")
                    .font(.system(size: 40, weight: .black, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .foregroundColor(isWin ? .green : .red)
                    .shadow(color: isWin ? .green.opacity(0.5) : .red.opacity(0.5), radius: 10)
                
                // SCORE CARD
                VStack(spacing: 15) {
                    HStack {
                        Text("TARGET:")
                            .font(.monospaced(.caption)())
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(targetScore)")
                            .font(.monospaced(.title3)())
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Divider().background(Color.white.opacity(0.3))
                    
                    HStack {
                        Text("YOU:")
                            .font(.monospaced(.caption)())
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(yourScore)")
                            .font(.monospaced(.title)())
                            .fontWeight(.heavy)
                            .foregroundColor(isWin ? .green : .red)
                    }
                }
                .padding(20)
                .background(Color.black.opacity(0.4))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isWin ? Color.green.opacity(0.5) : Color.red.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal, 40)
                .opacity(opacityEffect)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("RETURN TO BASE")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 1))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scaleEffect = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                opacityEffect = 1.0
            }
        }
    }
}

// MARK: - PREVIEWS
#Preview("Game Over - High Score") {
    let manager = GameManager()
    manager.currentScore = 42
    manager.isNewHighScore = true
    return GameOverView_iPhone(gameManager: manager, previousScore: .constant(30))
        .environmentObject(AppState())
}

#Preview("Challenge Win") {
    let manager = GameManager()
    manager.challengeOutcome = .win
    manager.challengeTarget = 30
    manager.currentScore = 35
    return GameOverView_iPhone(gameManager: manager, previousScore: .constant(30))
        .environmentObject(AppState())
}
