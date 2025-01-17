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

    func handleAchievements(for score: Int) -> String? {
        var achievementID = ""
        var achievementMessage: String? = nil

        switch score {
        case 0..<25:
            achievementMessage = "Every pro starts somewhere. \nYour journey just began! 🌟 \n\nDon’t stop now – the button’s getting nervous!"
        case 25..<35:
            achievementMessage = "You’re warming up. \nGreatness is just a few clicks away! ⚡\n\nKeep at it – the leaderboard is calling your name!"
        case 35..<50:
            achievementID = "seven.seconds.dedicated.player"
            achievementMessage = "Dedicated player alert. \nYou’re officially in the game now! 🎯\n\nNow go smash that button like it owes you money!"
        case 50..<70:
            achievementID = "seven.seconds.super.player"
            achievementMessage = "Super player unlocked. \nYou’re crushing it – what’s next? 💥\n\nKeep going – the button might file a restraining order!"
        case 70..<90:
            achievementID = "seven.seconds.master"
            achievementMessage = "Master status achieved. \nThat’s some serious button-smashing talent! 👑\n\nPush harder – you’re one click away from greatness!"
        case 90..<110:
            achievementID = "seven.seconds.super.hero"
            achievementMessage = "Legends play like this. \nLeaderboard domination in progress! 🏆\n\nKeep smashing – you’re the hero this button deserves!"
        case 110..<125:
            achievementID = "seven.seconds.god"
            achievementMessage = "Did you just bend time? \nThe button fears you now. Respect!\n\nThe gods are watching – don’t let them down!"
        case 125...1000:
            achievementID = "seven.seconds.cheater"
            achievementMessage = "Are your fingers okay? \nIf this is cheating, you’re the Picasso of it. 🎨\n\nJust make sure your button doesn’t explode! 😅"
        default:
            break
        }

        if !achievementID.isEmpty {
            GameCenterManager.shared.reportAchievement(achievementID: achievementID, percentComplete: 100)
        }

        return achievementMessage
    }
}

