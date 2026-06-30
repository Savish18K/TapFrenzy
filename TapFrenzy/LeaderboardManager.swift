import Foundation

class LeaderboardManager {

    static let shared = LeaderboardManager()

    private init() {}

    func loadScores(for game: String) -> [ScoreEntry] {

        guard let data = UserDefaults.standard.data(forKey: game) else {
            return []
        }

        let decoder = JSONDecoder()

        return (try? decoder.decode([ScoreEntry].self, from: data)) ?? []
    }

    func saveScore(playerName: String,
                   score: Int,
                   game: String) {

        var scores = loadScores(for: game)

        let newEntry = ScoreEntry(
            playerName: playerName,
            score: score,
            date: Date()
        )

        scores.append(newEntry)

        scores.sort {
            $0.score > $1.score
        }

        if scores.count > 20 {
            scores = Array(scores.prefix(20))
        }

        let encoder = JSONEncoder()

        if let encoded = try? encoder.encode(scores) {
            UserDefaults.standard.set(encoded, forKey: game)
        }
    }
}
