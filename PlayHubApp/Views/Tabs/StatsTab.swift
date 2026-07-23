import SwiftUI
import Charts

struct StatsTab: View {
    @StateObject private var store = SessionStore.shared
    @State private var selectedMode: GameMode
    
    init(initialMode: GameMode = .tapFrenzy) {
        _selectedMode = State(initialValue: initialMode)
    }
    
    // Filter sessions by the selected tab mode
    var filteredSessions: [GameSession] {
        store.sessions.filter { $0.mode == selectedMode }
    }
    
    // Leaderboard uses the top scores for the selected mode
    var topScores: [GameSession] {
        filteredSessions.sorted { $0.score > $1.score }.prefix(10).map { $0 }
    }
    
    // Recent scores for the chart
    var recentScores: [GameSession] {
        filteredSessions.suffix(15).map { $0 }
    }
    
    // Average score of recent games
    var averageRecentScore: Double {
        guard !recentScores.isEmpty else { return 0 }
        let total = recentScores.reduce(0) { $0 + $1.score }
        return Double(total) / Double(recentScores.count)
    }
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 0) {
                Text("STATISTICS")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                
                // Game Mode Tabs
                Picker("Game Mode", selection: $selectedMode) {
                    Text("Tap Frenzy").tag(GameMode.tapFrenzy)
                    Text("Light It Up").tag(GameMode.lightItUp)
                    Text("Quiz Rush").tag(GameMode.quizRush)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 24)
                .colorScheme(.dark) 
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Top Stats for Mode
                        HStack(spacing: 20) {
                            statCard(title: "Games Played", value: "\(store.totalGames(for: selectedMode))", color: selectedMode.color)
                            statCard(title: "Best Score", value: "\(store.bestScore(for: selectedMode))", color: selectedMode.color)
                        }
                        .padding(.horizontal)
                        
                        if filteredSessions.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "gamecontroller")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                    .padding(.top, 60)
                                Text("No games played yet in this mode.\nPlay a game to see stats!")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                            }
                        } else {
                            // LEADERBOARD (Top Scores) at the TOP
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Leaderboard - Top 10")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 8) {
                                    ForEach(Array(topScores.enumerated()), id: \.element.id) { index, session in
                                        HStack {
                                            Text("#\(index + 1)")
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                                .frame(width: 35, alignment: .leading)
                                            
                                            Text(session.playerName)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            
                                            Spacer()
                                            
                                            Text("\(session.score)")
                                                .font(.title3)
                                                .fontWeight(.black)
                                                .foregroundColor(selectedMode.color)
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // CHART (Recent Scores) at the BOTTOM
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Trend")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Chart {
                                    // Average Line
                                    RuleMark(
                                        y: .value("Average", averageRecentScore)
                                    )
                                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                                    .foregroundStyle(.gray.opacity(0.8))
                                    .annotation(position: .top, alignment: .leading) {
                                        Text("AVG: \(Int(averageRecentScore))")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    ForEach(Array(recentScores.enumerated()), id: \.element.id) { index, session in
                                        BarMark(
                                            x: .value("Game", "G\(index + 1)"),
                                            y: .value("Score", session.score),
                                            width: .fixed(22)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [selectedMode.color, selectedMode.color.opacity(0.4)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .cornerRadius(6)
                                        .annotation(position: .top, spacing: 4) {
                                            Text("\(session.score)")
                                                .font(.system(size: 9, weight: .bold))
                                                .foregroundColor(selectedMode.color)
                                        }
                                    }
                                }
                                .frame(height: 240)
                                .chartXAxis {
                                    AxisMarks(values: .automatic) { _ in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.gray.opacity(0.2))
                                        AxisValueLabel()
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 10, weight: .medium))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading) { _ in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.gray.opacity(0.2))
                                        AxisValueLabel()
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 10, weight: .medium))
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func statCard(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 28, weight: .black))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

#Preview {
    StatsTab()
}
