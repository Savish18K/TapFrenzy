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
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
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
                .colorScheme(.dark) // ensure picker looks good on black background
                
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
                                    ForEach(Array(recentScores.enumerated()), id: \.element.id) { index, session in
                                        LineMark(
                                            x: .value("Game", index + 1),
                                            y: .value("Score", session.score)
                                        )
                                        .interpolationMethod(.catmullRom)
                                        .foregroundStyle(selectedMode.color)
                                        .lineStyle(StrokeStyle(lineWidth: 3))
                                        
                                        PointMark(
                                            x: .value("Game", index + 1),
                                            y: .value("Score", session.score)
                                        )
                                        .foregroundStyle(selectedMode.color)
                                    }
                                }
                                .frame(height: 200)
                                .chartXAxis {
                                    AxisMarks(values: .automatic) { _ in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.gray.opacity(0.3))
                                        AxisValueLabel().foregroundStyle(.gray)
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading) { _ in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.gray.opacity(0.3))
                                        AxisValueLabel().foregroundStyle(.gray)
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
