//
//  GameOverView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//

//
//  GameOverView_iPad.swift
//  Seven Seconds Champions
//
//  Created by Boseanu on 04.02.2026.
//

import SwiftUI
import AVFoundation
import GameKit
import StoreKit

// MARK: - MAIN VIEW (WRAPPER)
struct GameOverView_iPad: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var gameManager: GameManager
    
    @Binding var previousScore: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) var requestReview
    
    // FACTORUL DE SCALARE (TANC MODE)
    let scale: CGFloat = 1.6
    
    var body: some View {
        Group {
            if let challengeOutcome = gameManager.challengeOutcome, let target = gameManager.challengeTarget {
                // Dacă a fost o provocare
                ChallengeResultView_iPad(
                    challengeOutcome: challengeOutcome,
                    yourScore: gameManager.currentScore,
                    targetScore: target,
                    scale: scale
                )
            } else {
                // Game Over Normal
                NormalGameOverView_iPad(
                    gameManager: gameManager,
                    previousScore: $previousScore,
                    scale: scale
                )
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

// MARK: - ECRAN NORMAL GAME OVER (IPAD VERSION)
struct NormalGameOverView_iPad: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var gameManager: GameManager
    
    @Binding var previousScore: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) var requestReview
    
    var scale: CGFloat // Primim scara de la părinte
    
    @State private var showNewHighScoreAlert = false
    @State private var areParticlesActive: Bool = false
    
    // Animations
    @State private var scaleTitle: CGFloat = 0.5
    @State private var opacityTitle: Double = 0
    @State private var scoreScale: CGFloat = 0.8
    @State private var buttonOffset: CGFloat = 50 * 1.6
    @State private var buttonOpacity: Double = 0
    
    private var challengeText: String {
        let redirectPageURL = "https://ovidiumuntean-imawo.github.io/7seconds-challenge-redirect/redirect.html"
        let finalURL = "\(redirectPageURL)?score=\(gameManager.currentScore)"
        return "I challenge you to 7 Seconds! I scored \(gameManager.currentScore) taps. Can you beat that? \(finalURL)"
    }
    
    var body: some View {
        ZStack {
            // 1. FUNDAL
            NormalBackground().ignoresSafeArea()
            
            // 2. PARTICULE
            ParticleView(isActive: $areParticlesActive).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // --- TITLU MASSIVE ---
                Text("GAME OVER")
                    .font(.system(size: 52 * scale, weight: .black, design: .monospaced)) // Font Uriaș
                    .foregroundColor(.white)
                    .shadow(color: .neonRed, radius: 10 * scale, x: 0, y: 0)
                    .shadow(color: .neonRed.opacity(0.5), radius: 20 * scale, x: 0, y: 0)
                    .scaleEffect(scaleTitle)
                    .opacity(opacityTitle)
                
                Spacer().frame(height: 60 * scale)
                
                // --- SCOR ---
                VStack(spacing: 15 * scale) {
                    Text("YOU SCORED")
                        .font(.system(size: 16 * scale, weight: .bold, design: .monospaced))
                        .tracking(4 * scale)
                        .foregroundColor(.neonCyan.opacity(0.7))
                    
                    ZStack {
                        // Glow spate
                        Circle()
                            .fill(RadialGradient(colors: [.neonBlue.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 150 * scale))
                            .frame(width: 300 * scale, height: 120 * scale)
                        
                        Text("\(gameManager.currentScore)")
                            .font(.system(size: 90 * scale, weight: .black, design: .rounded)) // Număr GIGANT
                            .foregroundColor(.white)
                            .shadow(color: .neonCyan, radius: 10 * scale)
                            .scaleEffect(scoreScale)
                    }
                    
                    Text("TAPS")
                        .font(.system(size: 20 * scale, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                // --- BUTOANE (LATE ȘI UȘOR DE APĂSAT) ---
                VStack(spacing: 25 * scale) {
                    
                    // 1. PLAY AGAIN
                    Button(action: { restartGame() }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("RETRY MISSION")
                        }
                        .font(.system(size: 20 * scale, weight: .bold, design: .rounded))
                        .frame(maxWidth: 400 * scale) // Limităm lățimea să nu fie cât tot iPad-ul
                        .padding(.vertical, 16 * scale)
                        .background(Color.neonCyan.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(16 * scale)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16 * scale)
                                .stroke(Color.neonCyan, lineWidth: 2 * scale)
                                .shadow(color: .neonCyan, radius: 5 * scale)
                        )
                    }
                    
                    // 2. CHALLENGE FRIEND
                    ShareLink(item: challengeText) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("CHALLENGE FRIEND")
                        }
                        .font(.system(size: 16 * scale, weight: .bold, design: .monospaced))
                        .frame(maxWidth: 400 * scale)
                        .padding(.vertical, 14 * scale)
                        .background(Color.neonPurple.opacity(0.15))
                        .foregroundColor(.neonPurple)
                        .cornerRadius(12 * scale)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12 * scale)
                                .stroke(Color.neonPurple.opacity(0.5), lineWidth: 1 * scale)
                        )
                    }
                    
                    // 3. LEADERBOARD
                    Button(action: { openLeaderboard() }) {
                        VStack(spacing: 5 * scale) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 24 * scale))
                            Text("RANKS")
                                .font(.system(size: 12 * scale, weight: .bold))
                        }
                        .frame(maxWidth: 400 * scale)
                        .padding(.vertical, 12 * scale)
                        .background(Color.white.opacity(0.05))
                        .foregroundColor(.yellow)
                        .cornerRadius(12 * scale)
                        .overlay(RoundedRectangle(cornerRadius: 12 * scale).stroke(Color.yellow.opacity(0.3), lineWidth: 1 * scale))
                    }
                }
                .padding(.horizontal, 40 * scale)
                .offset(y: buttonOffset)
                .opacity(buttonOpacity)
                
                Spacer().frame(height: 60 * scale)
            }
        }
        .onAppear {
            animateEntrance()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { areParticlesActive = true }
            if gameManager.isNewHighScore {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { showNewHighScoreAlert = true }
            }
        }
        .onDisappear { areParticlesActive = false }
        .alert(isPresented: $showNewHighScoreAlert) {
            Alert(
                title: Text("NEW RECORD! 🚀"),
                message: Text("UNBELIEVABLE!\nYou hit \(gameManager.currentScore) taps.\nLEGENDARY STATUS."),
                dismissButton: .default(Text("Let's Go!"), action: { requestReview() })
            )
        }
    }
    
    // Helpers
    private func restartGame() {
        previousScore = gameManager.currentScore
        dismiss()
    }
    private func openLeaderboard() {
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            GameCenterManager.shared.showLeaderboard(from: rootVC)
        }
    }
    private func animateEntrance() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scaleTitle = 1.0; opacityTitle = 1.0
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.2)) {
            scoreScale = 1.0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            buttonOffset = 0; buttonOpacity = 1.0
        }
    }
}

// MARK: - CHALLENGE RESULT (IPAD VERSION)
struct ChallengeResultView_iPad: View {
    @Environment(\.dismiss) private var dismiss
    var challengeOutcome: ChallengeOutcome
    var yourScore: Int
    var targetScore: Int
    var scale: CGFloat // Factorul de scalare
    
    @State private var scaleEffect: CGFloat = 0.5
    @State private var opacityEffect: Double = 0
    
    var isWin: Bool { return challengeOutcome == .win }
    
    var body: some View {
        ZStack {
            NormalBackground().ignoresSafeArea()
            
            VStack(spacing: 30 * scale) {
                Spacer()
                
                // ICON
                Image(systemName: isWin ? "trophy.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 80 * scale))
                    .foregroundColor(isWin ? .green : .red)
                    .shadow(color: isWin ? .green : .red, radius: 20 * scale)
                    .scaleEffect(scaleEffect)
                
                // TEXT STATUS
                Text(isWin ? "MISSION\nACCOMPLISHED" : "MISSION\nFAILED")
                    .font(.system(size: 40 * scale, weight: .black, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .foregroundColor(isWin ? .green : .red)
                    .shadow(color: isWin ? .green.opacity(0.5) : .red.opacity(0.5), radius: 10 * scale)
                
                // SCORE CARD
                VStack(spacing: 15 * scale) {
                    HStack {
                        Text("TARGET:")
                            .font(.system(size: 14 * scale, design: .monospaced))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(targetScore)")
                            .font(.system(size: 24 * scale, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    Divider().background(Color.white.opacity(0.3))
                    HStack {
                        Text("YOU:")
                            .font(.system(size: 14 * scale, design: .monospaced))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(yourScore)")
                            .font(.system(size: 32 * scale, weight: .heavy, design: .monospaced))
                            .foregroundColor(isWin ? .green : .red)
                    }
                }
                .padding(20 * scale)
                .background(Color.black.opacity(0.4))
                .cornerRadius(12 * scale)
                .overlay(
                    RoundedRectangle(cornerRadius: 12 * scale)
                        .stroke(isWin ? Color.green.opacity(0.5) : Color.red.opacity(0.5), lineWidth: 1 * scale)
                )
                .frame(maxWidth: 500 * scale) // Carte mai lată pe iPad
                .opacity(opacityEffect)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("RETURN TO BASE")
                        .font(.system(size: 18 * scale, weight: .bold, design: .monospaced))
                        .frame(maxWidth: 400 * scale)
                        .padding(16 * scale)
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                        .cornerRadius(12 * scale)
                        .overlay(RoundedRectangle(cornerRadius: 12 * scale).stroke(Color.white, lineWidth: 1 * scale))
                }
                .padding(.bottom, 60 * scale)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) { scaleEffect = 1.0 }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) { opacityEffect = 1.0 }
        }
    }
}

#Preview("iPad GameOver - HighScore") {
    let manager = GameManager()
    manager.currentScore = 55
    manager.isNewHighScore = true
    
    return GameOverView_iPad(gameManager: manager, previousScore: .constant(40))
        .environmentObject(AppState())
        .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch)"))
}

#Preview("iPad GameOver - Challenge Win") {
    let manager = GameManager()
    manager.challengeOutcome = .win
    manager.challengeTarget = 50
    manager.currentScore = 52
    
    return GameOverView_iPad(gameManager: manager, previousScore: .constant(50))
        .environmentObject(AppState())
        .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch)"))
}
