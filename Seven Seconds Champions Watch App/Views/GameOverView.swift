//
//  GameOverView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//


import SwiftUI
import AVFoundation
import GameKit

// MARK: - GameOverView_Watch
struct GameOverView_Watch: View {
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
                    .blur(radius: 10)
                
                VStack(spacing: 0) {
                    Text("game over")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(.white)
                        .padding(.top, -36)
                    
                    Spacer()
                    
                    Text("YOU SCORED")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.white)
                        .padding(.top, 8)
                    
                    Text("\(score)")
                        .font(.system(size: 48, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.top, -4)
                    
                    Text("HITS")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.top, -4)
                    
                    Spacer()
                    
                    Button(action: {
                        previousScore = score
                        dismiss()
                    }) {
                        Text("Play again!")
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    /*Text("How other players are doing?")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                    
                    Button("View high scores") {
                        showLeaderboardFromGameOver = true
                    }
                    .background(Color.red)
                    .sheet(isPresented: $showLeaderboardFromGameOver) {
                        // LeaderboardView()
                    }
                    
                    Spacer()*/
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
            .onAppear {
                
            }
        }
    }
}

#Preview {
    @Previewable @State var previousScore = 0
    return GameOverView_Watch(score: 10, previousScore: $previousScore)
}
