//
//  AchievementManager.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 16.01.2025.
//

import UIKit
import GameKit

class AchievementManager {
    static let shared = AchievementManager()
    private init() {}

    func handleAchievements(for score: Int) {
        var achievementID = ""
        var achievementMessage = ""

        switch score {
        case 0..<10:
            achievementMessage = "Seriously?"
        case 10..<25:
            achievementMessage = "Nice one!"
        case 25..<45:
            achievementID = "seven.seconds.dedicated.player"
            achievementMessage = "You are now: SEVEN SECONDS DEDICATED PLAYER!"
        case 45..<70:
            achievementID = "seven.seconds.super.player"
            achievementMessage = "You are now: SEVEN SECONDS SUPER PLAYER!"
        case 70..<90:
            achievementID = "seven.seconds.master"
            achievementMessage = "You are now: SEVEN SECONDS MASTER!"
        case 90..<110:
            achievementID = "seven.seconds.super.hero"
            achievementMessage = "You are now: SEVEN SECONDS SUPER HERO!"
        case 110..<145:
            achievementID = "seven.seconds.god"
            achievementMessage = "You are now: SEVEN SECONDS GOD!"
        case 145...1000:
            achievementID = "seven.seconds.cheater"
            achievementMessage = "You are a SEVEN SECONDS CHEATER!"
        default:
            break
        }

        if !achievementID.isEmpty {
            GameCenterManager.shared.reportAchievement(achievementID: achievementID, percentComplete: 100)
        }

        if !achievementMessage.isEmpty {
            DispatchQueue.main.async {
                self.showAchievementAlert(message: achievementMessage)
            }
        }
    }

    private func showAchievementAlert(message: String) {
        let alert = UIAlertController(title: "Achievement Unlocked!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Show Achievements", style: .default) { _ in
            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                GameCenterManager.shared.showAchievements(from: rootVC)
            }
        })
        alert.addAction(UIAlertAction(title: "Show Leaderboard", style: .default) { _ in
            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                GameCenterManager.shared.showLeaderboard(from: rootVC)
            }
        })
        
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
}
