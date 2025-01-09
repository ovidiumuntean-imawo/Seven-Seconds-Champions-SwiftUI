//
//  GameOverView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//


import SwiftUI
import AVFoundation
import GameKit

// MARK: - GameOverView
struct GameOverView: View {
    var score: Int
    @Binding var previousScore: Int
    @Environment(\.dismiss) private var dismiss
    
    @State private var showLeaderboardFromGameOver = false
    
    var body: some View {
        GeometryReader { containerGeo in
            ZStack {
                // Background
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: containerGeo.size.width,
                           height: containerGeo.size.height)
                    .edgesIgnoringSafeArea(.all)
                
                VisualEffectBlur(style: .dark)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Text("game over")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Text("YOU SCORED")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                    
                    Text("\(score)")
                        .font(.system(size: 72, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.top, -12)
                    
                    Text("HITS")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.top, -12)
                    
                    Button(action: {
                        previousScore = score
                        dismiss()
                    }) {
                        Text("PLAY AGAIN")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 40)
                    
                    Text("How other players are doing?")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                    
                    Button("VIEW HIGH SCORES") {
                        showLeaderboardFromGameOver = true
                    }
                    .font(.system(size: 18))
                    .padding(.horizontal)
                    .frame(height: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .sheet(isPresented: $showLeaderboardFromGameOver) {
                        LeaderboardView()
                    }
                    
                    Spacer()
                    
                    Text("Share your best screenshots!")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                    
                    Button("Visit our FB Group") {
                        if let url = URL(string: "https://www.facebook.com/groups/sevensecondschampions") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.system(size: 18))
                    .padding(.horizontal)
                    .frame(height: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer()
                }
                .padding()
                .background(
                    Image("backgroundGameOver")
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 4)
                        .edgesIgnoringSafeArea(.all)
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var previousScore = 0
    return GameOverView(score: 10, previousScore: $previousScore)
}
