import Foundation

struct ScoreEntry: Codable, Identifiable {
    var id: UUID = UUID()
    let playerName: String
    let score: Int
    let date: Date
}

class LeaderboardManager {
    static let shared = LeaderboardManager()
    private init() {}
    
    func loadScores(for game: String) -> [ScoreEntry] {
        guard let data = UserDefaults.standard.data(forKey: "scores_\(game)") else {
            return []
        }
        return (try? JSONDecoder().decode([ScoreEntry].self, from: data)) ?? []
    }
    
    func saveScore(playerName: String, score: Int, game: String) {
        var scores = loadScores(for: game)
        let entry = ScoreEntry(
            playerName: playerName.isEmpty ? "Anonymous" : playerName,
            score: score,
            date: Date()
        )
        scores.append(entry)
        scores.sort { $0.score > $1.score }
        if scores.count > 20 {
            scores = Array(scores.prefix(20))
        }
        if let encoded = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(encoded, forKey: "scores_\(game)")
        }
    }
}
