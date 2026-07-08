import SwiftUI
import Charts

struct StatsTab: View {
    @StateObject private var store = SessionStore.shared
    
    // Optional init to accept game string if needed for compatibility, though we use the global store now
    var game: String? = nil
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Text("STATISTICS")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // Overall Stats
                    HStack(spacing: 20) {
                        statCard(title: "Total Games", value: "\(store.totalGamesPlayed)", color: .purple)
                        statCard(title: "Overall Best", value: "\(store.overallBestScore)", color: .purple)
                    }
                    .padding(.horizontal)
                    
                    // Mode Stats
                    VStack(spacing: 16) {
                        modeStatRow(mode: .tapFrenzy)
                        modeStatRow(mode: .lightItUp)
                        modeStatRow(mode: .quizRush)
                    }
                    .padding(.horizontal)
                    
                    // Chart
                    if !store.sessions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Scores")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Chart {
                                ForEach(store.sessions.suffix(15)) { session in
                                    BarMark(
                                        x: .value("Date", session.timestamp, unit: .minute),
                                        y: .value("Score", session.score)
                                    )
                                    .foregroundStyle(session.mode.color)
                                    .cornerRadius(4)
                                }
                            }
                            .frame(height: 200)
                            .chartXAxis {
                                AxisMarks(values: .automatic) { _ in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.gray.opacity(0.3))
                                    AxisTick(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.gray.opacity(0.3))
                                    AxisValueLabel(format: .dateTime.month().day(), centered: true).foregroundStyle(.gray)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading) { _ in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.gray.opacity(0.3))
                                    AxisTick(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.gray.opacity(0.3))
                                    AxisValueLabel().foregroundStyle(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Recent Games List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent History")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            ForEach(store.sessions.reversed().prefix(20)) { session in
                                HStack {
                                    Circle()
                                        .fill(session.mode.color)
                                        .frame(width: 12, height: 12)
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(session.mode.rawValue) - \(session.playerName)")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(session.score)")
                                        .font(.title3)
                                        .fontWeight(.black)
                                        .foregroundColor(session.mode.color)
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "gamecontroller")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No games played yet.\nPlay a game to see stats!")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 40)
                    }
                }
                .padding(.bottom, 40)
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
    
    private func modeStatRow(mode: GameMode) -> some View {
        HStack {
            Text(mode.rawValue)
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            VStack(alignment: .trailing) {
                Text("Best: \(store.bestScore(for: mode))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(mode.color)
                Text("Games: \(store.totalGames(for: mode))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    StatsTab()
}
