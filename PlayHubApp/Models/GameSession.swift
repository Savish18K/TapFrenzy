import Foundation

struct GameSession: Codable, Identifiable {
    var id: UUID = UUID()
    let playerName: String
    let score: Int
    let date: Date
}

class GameSessionManager {
    static let shared = GameSessionManager()
    private init() {}
    
    func loadScores(for game: String) -> [GameSession] {
        guard let data = UserDefaults.standard.data(forKey: "scores_\(game)") else {
            return []
        }
        return (try? JSONDecoder().decode([GameSession].self, from: data)) ?? []
    }
    
    func saveScore(playerName: String, score: Int, game: String) {
        var scores = loadScores(for: game)
        let entry = GameSession(
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
