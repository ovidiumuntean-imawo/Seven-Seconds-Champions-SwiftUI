//
//  GameCenterManager.swift
//  seven.seconds
//
//  Created by Ovidiu Muntean on 09.01.2025.
//

import GameKit

class GameCenterManager {
    private var isGameCenterEnabled = false
    private var leaderboardID = "seven.seconds.leaderboard"
    
    static let shared = GameCenterManager()
    private init() {}

    // Authenticate the local player silently on watchOS
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { error in
            if let error = error {
                print("Game Center auth error: \(error.localizedDescription)")
                self.isGameCenterEnabled = false
                return
            }
            
            if localPlayer.isAuthenticated {
                self.isGameCenterEnabled = true
                localPlayer.loadDefaultLeaderboardIdentifier { leaderboardID, error in
                    if let leaderboardID = leaderboardID {
                        self.leaderboardID = leaderboardID
                    } else {
                        print("Failed to load leaderboard identifier: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            } else {
                self.isGameCenterEnabled = false
                print("Player is not authenticated")
            }
        }
    }

    // Submit a score to the leaderboard
    func submitScore(with value: Int) {
        guard isGameCenterEnabled else {
            print("Game Center is not enabled")
            return
        }
        
        let score = GKScore(leaderboardIdentifier: leaderboardID)
        score.value = Int64(value)
        GKScore.report([score]) { error in
            if let error = error {
                print("Error reporting score: \(error.localizedDescription)")
            } else {
                print("Score submitted successfully")
            }
        }
    }

    // Check if Game Center is enabled
    func gameCenterEnabled() -> Bool {
        return isGameCenterEnabled
    }
}
