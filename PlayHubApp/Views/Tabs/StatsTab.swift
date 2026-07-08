import SwiftUI

struct StatsTab: View {
    let game: String
    @State private var scores: [GameSession] = []
    
    var color: Color {
        switch game {
        case "TapFrenzy": return .green
        case "LightItUp": return .blue
        case "QuizRush": return .orange
        default: return .white
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("🏆 Leaderboard")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(color)
                    .padding(.top, 20)
                
                if scores.isEmpty {
                    Spacer()
                    Text("No scores yet!\nPlay a game first.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(scores.indices, id: \.self) { i in
                                HStack(spacing: 12) {
                                    
                                    // rank circle
                                    ZStack {
                                        Circle()
                                            .fill(medalColor(i))
                                            .frame(width: 36, height: 36)
                                        Text("#\(i + 1)")
                                            .font(.system(size: 13, weight: .black))
                                            .foregroundColor(.black)
                                    }
                                    
                                    // name + date
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(scores[i].playerName)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                        Text(formatDate(scores[i].date))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    // score
                                    Text("\(scores[i].score)")
                                        .font(.system(size: 24, weight: .black))
                                        .foregroundColor(color)
                                }
                                .padding(14)
                                .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    }
                }
            }
        }
        .onAppear {
            scores = GameSessionManager.shared.loadScores(for: game)
        }
    }
    
    func medalColor(_ index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return Color(white: 0.75)
        case 2: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return Color(white: 0.3)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy  h:mm a"
        return f.string(from: date)
    }
}
