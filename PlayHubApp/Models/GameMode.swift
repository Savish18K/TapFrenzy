import Foundation
import SwiftUI

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case tapFrenzy = "Tap Frenzy"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .tapFrenzy: return .green
        case .lightItUp: return .blue
        case .quizRush: return .orange
        }
    }
}
