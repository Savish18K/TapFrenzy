import Foundation
import Combine

struct GameSession: Codable, Identifiable {
    var id: UUID = UUID()
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double
}

class SessionStore: ObservableObject {
    static let shared = SessionStore()
    
    @Published var sessions: [GameSession] = []
    
    private let sessionsKey = "saved_sessions"
    
    private init() {
        load()
    }
    
    func save(mode: GameMode, score: Int, lat: Double, lon: Double) {
        let session = GameSession(mode: mode, score: score, timestamp: Date(), latitude: lat, longitude: lon)
        sessions.append(session)
        persist()
    }
    
    func clearAll() {
        sessions.removeAll()
        persist()
    }
    
    func bestScore(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map { $0.score }.max() ?? 0
    }
    
    func totalGames(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.count
    }
    
    var overallBestScore: Int {
        sessions.map { $0.score }.max() ?? 0
    }
    
    var totalGamesPlayed: Int {
        sessions.count
    }
    
    private func persist() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([GameSession].self, from: data) {
            self.sessions = decoded
        }
    }
}
