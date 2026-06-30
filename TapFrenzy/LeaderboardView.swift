import SwiftUI

struct LeaderboardView: View {

    let game: String

    var scores: [ScoreEntry] {
        LeaderboardManager.shared.loadScores(for: game)
    }

    var body: some View {

        NavigationStack {

            List {

                ForEach(scores.indices, id: \.self) { index in

                    let player = scores[index]

                    HStack {

                        Text("#\(index+1)")
                            .bold()
                            .frame(width:40)

                        VStack(alignment:.leading){

                            Text(player.playerName)
                                .font(.headline)

                            Text(player.date.formatted())
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Text("\(player.score)")
                            .font(.title3.bold())
                    }
                }
            }
            .navigationTitle("\(game) Leaderboard")
        }
    }
}
