import Foundation
import SwiftUI

struct DailyChallenge {
    let gameMode: GameMode
    let challengeText: String
    let emoji: String
    
    // Returns a deterministic challenge for the current day.
    static func today() -> DailyChallenge {
        let calendar = Calendar.current
        let day = calendar.ordinality(of: .day, in: .era, for: Date()) ?? 0
        
        // Use day-of-era as a simple seed for deterministic selection
        let modes = GameMode.allCases
        let modeIndex = day % modes.count
        let selectedMode = modes[modeIndex]
        
        let challenges: [GameMode: [(text: String, emoji: String)]] = [
            .tapFrenzy: [
                ("Score 30+ in Tap Frenzy!", "🔥"),
                ("Get a 5x combo streak!", "🔥"),
                ("Beat your Tap Frenzy record!", "🔥"),
                ("Score 50+ taps today!", "🔥"),
            ],
            .lightItUp: [
                ("Score 15+ in Light It Up!", "💡"),
                ("Survive 10 rounds!", "💡"),
                ("Beat your Light It Up best!", "💡"),
                ("React faster than ever!", "💡"),
            ],
            .quizRush: [
                ("Get 8/10 correct!", "🧠"),
                ("Score 60+ points!", "🧠"),
                ("Perfect streak of 5!", "🧠"),
                ("Beat your Quiz Rush best!", "🧠"),
            ],
        ]
        
        let options = challenges[selectedMode] ?? [("Play a game today!", "🎮")]
        let challengeIndex = (day / modes.count) % options.count
        let selected = options[challengeIndex]
        
        return DailyChallenge(
            gameMode: selectedMode,
            challengeText: selected.text,
            emoji: selected.emoji
        )
    }
}
