import Foundation

struct ScoreEntry: Codable, Identifiable {

    let id: UUID
    let playerName: String
    let score: Int
    let date: Date

    init(
        id: UUID = UUID(),
        playerName: String,
        score: Int,
        date: Date = Date()
    ) {
        self.id = id
        self.playerName = playerName
        self.score = score
        self.date = date
    }
}
