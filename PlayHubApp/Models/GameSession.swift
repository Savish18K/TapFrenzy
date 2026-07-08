import Foundation
import Combine

struct GameSession: Codable, Identifiable {
    var id: UUID = UUID()
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    var playerName: String = "Anonymous"
    
    enum CodingKeys: String, CodingKey {
        case id, mode, score, timestamp, latitude, longitude, playerName
    }
    
    init(id: UUID = UUID(), mode: GameMode, score: Int, timestamp: Date, latitude: Double, longitude: Double, playerName: String) {
        self.id = id
        self.mode = mode
        self.score = score
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.playerName = playerName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.mode = try container.decode(GameMode.self, forKey: .mode)
        self.score = try container.decode(Int.self, forKey: .score)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.playerName = try container.decodeIfPresent(String.self, forKey: .playerName) ?? "Anonymous"
    }
}

class SessionStore: ObservableObject {
    static let shared = SessionStore()
    
    @Published var sessions: [GameSession] = []
    
    private let sessionsKey = "saved_sessions"
    
    private init() {
        load()
    }
    
    func save(mode: GameMode, score: Int, lat: Double, lon: Double, playerName: String) {
        // Add a tiny random jitter (approx ~50 meters) so pins from the same location fan out
        let jLat = lat + Double.random(in: -0.0005...0.0005)
        let jLon = lon + Double.random(in: -0.0005...0.0005)
        
        let session = GameSession(mode: mode, score: score, timestamp: Date(), latitude: jLat, longitude: jLon, playerName: playerName)
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
