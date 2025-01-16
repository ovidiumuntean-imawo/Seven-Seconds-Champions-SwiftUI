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
            achievementMessage = "Every pro starts somewhere – your journey just began! 🌟"
        case 10..<25:
            achievementMessage = "You’re warming up – greatness is just a few clicks away! ⚡"
        case 25..<45:
            achievementID = "seven.seconds.dedicated.player"
            achievementMessage = "Dedicated player alert! You’re officially in the game now! 🎯"
        case 45..<70:
            achievementID = "seven.seconds.super.player"
            achievementMessage = "Super player unlocked! You’re crushing it – what’s next? 💥"
        case 70..<90:
            achievementID = "seven.seconds.master"
            achievementMessage = "Master status achieved! That’s some serious button-smashing talent! 👑"
        case 90..<110:
            achievementID = "seven.seconds.super.hero"
            achievementMessage = "Legends play like this! Superhero reflexes detected. Leaderboard domination in progress! 🏆"
        case 110..<125:
            achievementID = "seven.seconds.god"
            achievementMessage = "Did you just bend time? The button fears you now. Respect!"
        case 125...1000:
            achievementID = "seven.seconds.cheater"
            achievementMessage = "Are your fingers okay? If this is cheating, you’re the Picasso of it. 🎨"
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
