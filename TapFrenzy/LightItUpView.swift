import SwiftUI
import Combine

struct Level {
    let cardCount: Int
    let litWindow: Double   // seconds the card stays lit
    let litCount: Int
    let color: Color
    let name: String
    let scoreThreshold: Int  // minimum score to reach this level
}

struct Card: Identifiable {
    let id: Int
    var isLit: Bool = false
    var wasTapped: Bool = false  // prevents double-tap scoring
}

struct LightItUpView: View {

    @Environment(\.dismiss) var dismiss

    @AppStorage("lightItUpHighScore") private var highScore = 0

    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var lives = 4
    @State private var timeRemaining = 60
    @State private var gameStarted = false
    @State private var gameOver = false
    @State private var currentLevel = 0
    @State private var showLevelUp = false
    @State private var playerName = ""
    @State private var showNameSheet = false
    @State private var lostLifeFlash = false   // brief  flash on life lost

    
    @State private var generation = 0


    let roundTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Score thresholds: L1=0, L2=30, L3=70, L4=120
    let levels = [
        Level(cardCount: 3, litWindow: 2.0, litCount: 1, color: .green,  name: "L1", scoreThreshold: 0),
        Level(cardCount: 4, litWindow: 1.6, litCount: 1, color: .blue,   name: "L2", scoreThreshold: 30),
        Level(cardCount: 6, litWindow: 1.2, litCount: 1, color: .yellow, name: "L3", scoreThreshold: 70),
        Level(cardCount: 9, litWindow: 0.9, litCount: 2, color: .red,    name: "L4", scoreThreshold: 120)
    ]

    var level: Level { levels[currentLevel] }

    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    }

  
    // MARK: Body
    // ─────────────────────────────────────────────────────────────────────
    var body: some View {
        ZStack {
            // Background — flashes red briefly when a life is lost
            (lostLifeFlash ? Color.red.opacity(0.25) : Color.black)
                .ignoresSafeArea()
                .animation(.easeOut(duration: 0.25), value: lostLifeFlash)

            if !gameStarted {
                startScreen
            } else if gameOver {
                gameOverScreen
            } else {
                gameScreen
            }

            // Level-up overlay
            if showLevelUp {
                Color.white.opacity(0.12)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                VStack(spacing: 6) {
                    Text("LEVEL UP!")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.white)
                    Text(level.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(level.color)
                }
                .allowsHitTesting(false)
            }
        }
        .navigationBarHidden(true)
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Circle().fill(Color.white.opacity(0.2)))
            }
            .padding(.leading, 16)
        }
        .sheet(isPresented: $showNameSheet) {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 20) {
                    Text(lives == 0 ? "No Lives Left!" : "Time's Up!")
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(.blue)
                    Text("Your Score: \(score)")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.white)
                    Text("Enter your name to save")
                        .foregroundColor(.gray)
                    TextField("Your name", text: $playerName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 30)
                    Button {
                        LeaderboardManager.shared.saveScore(
                            playerName: playerName,
                            score: score,
                            game: "LightItUp"
                        )
                        playerName = ""
                        showNameSheet = false
                    } label: {
                        Text("SAVE & CONTINUE")
                            .font(.system(size: 17, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 30)
                    }
                }
                .padding()
            }
            .presentationDetents([.medium])
        }
        .onReceive(roundTimer) { _ in
            guard gameStarted && !gameOver else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // MARK: Start screen
    // ─────────────────────────────────────────────────────────────────────
    var startScreen: some View {
        VStack(spacing: 30) {
            Text("LIGHT IT UP")
                .font(.system(size: 42, weight: .black))
                .foregroundColor(.blue)

            Text("Tap the lit card before\nit goes dark!")
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.title3)
                .padding(.horizontal, 30)

            if highScore > 0 {
                Text("Best: \(highScore)")
                    .foregroundColor(.yellow)
                    .font(.headline)
            }

            // Lives & level info
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    ForEach(0..<4) { _ in
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 18))
                    }
                    Text("4 lives")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Text("Level up by score: L2@30 · L3@70 · L4@120")
                    .font(.caption).foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            Button { startGame() } label: {
                Text("START")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.horizontal, 50)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }

            NavigationLink(destination: LeaderboardView(game: "LightItUp")) {
                HStack {
                    Image(systemName: "trophy.fill").foregroundColor(.yellow)
                    Text("Leaderboard")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 1.5))
                .padding(.horizontal, 40)
            }

            Button { dismiss() } label: {
                Text("Back to Home")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 1.5))
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // MARK: Game screen
    // ─────────────────────────────────────────────────────────────────────
    var gameScreen: some View {
        VStack(spacing: 0) {

            // ── HUD ──────────────────────────────────────────────────────
            HStack {
                // Score
                VStack(alignment: .leading, spacing: 2) {
                    Text("SCORE").font(.caption).foregroundColor(.gray)
                    Text("\(score)")
                        .font(.system(size: 38, weight: .black))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                }

                Spacer()

                // Lives — hearts
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        ForEach(0..<4) { i in
                            Image(systemName: i < lives ? "heart.fill" : "heart")
                                .foregroundColor(i < lives ? .red : .gray)
                                .font(.system(size: 20))
                                .animation(.bouncy, value: lives)
                        }
                    }
                    Text(level.name)
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(level.color)
                }

                Spacer()

                // Time
                VStack(alignment: .trailing, spacing: 2) {
                    Text("TIME").font(.caption).foregroundColor(.gray)
                    Text("\(timeRemaining)s")
                        .font(.system(size: 38, weight: .black))
                        .foregroundColor(timeRemaining <= 10 ? .red : .white)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)

            // Score-based level progress bar
            GeometryReader { geo in
                let nextThreshold = currentLevel < levels.count - 1
                    ? levels[currentLevel + 1].scoreThreshold
                    : levels[currentLevel].scoreThreshold
                let thisThreshold = level.scoreThreshold
                let progress: CGFloat = currentLevel == levels.count - 1
                    ? 1.0
                    : CGFloat(score - thisThreshold) / CGFloat(max(1, nextThreshold - thisThreshold))
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.08)).frame(height: 5)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(level.color.opacity(0.8))
                        .frame(width: max(0, min(geo.size.width, geo.size.width * progress)), height: 5)
                        .animation(.easeInOut(duration: 0.4), value: score)
                }
            }
            .frame(height: 5)
            .padding(.horizontal, 24)
            .padding(.top, 8)

            Spacer()

            // ── Card grid ────────────────────────────────────────────────
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(cards) { card in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(card.isLit ? level.color : Color(red: 0.15, green: 0.17, blue: 0.22))
                        .frame(height: 100)
                        .scaleEffect(card.isLit ? 1.06 : 1.0)
                        .shadow(color: card.isLit ? level.color.opacity(0.7) : .clear, radius: 14)
                        .animation(.easeInOut(duration: 0.15), value: card.isLit)
                        .onTapGesture {
                            cardTapped(card)
                        }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Text("Tap the glowing card!")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 40)
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // MARK: Game over screen
    // ─────────────────────────────────────────────────────────────────────
    var gameOverScreen: some View {
        VStack(spacing: 24) {
            Text(lives == 0 ? "NO LIVES LEFT!" : "TIME'S UP!")
                .font(.system(size: 40, weight: .black))
                .foregroundColor(.red)

            // Show remaining hearts
            HStack(spacing: 8) {
                ForEach(0..<4) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart")
                        .foregroundColor(i < lives ? .red : .gray)
                        .font(.system(size: 24))
                }
            }

            Text("Score").foregroundColor(.gray)
            Text("\(score)")
                .font(.system(size: 70, weight: .black))
                .foregroundColor(.white)

            if score > 0 && score >= highScore {
                Text("NEW HIGH SCORE!")
                    .font(.headline).foregroundColor(.yellow)
            } else {
                Text("Best: \(highScore)").foregroundColor(.gray)
            }

            Button { startGame() } label: {
                Text("PLAY AGAIN")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.horizontal, 44)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }

            Button { dismiss() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "gamecontroller.fill").font(.system(size: 14))
                    Text("Choose Another Game").font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 1.5))
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // MARK: Game logic
    // ─────────────────────────────────────────────────────────────────────

    func startGame() {
        score = 0
        lives = 4
        timeRemaining = 60
        gameOver = false
        currentLevel = 0
        generation += 1
        cards = (0..<levels[0].cardCount).map { Card(id: $0) }
        gameStarted = true
        // Short grace period before first card lights up
        scheduleNextLight(after: 0.6)
    }

    func endGame() {
        generation += 1
        gameStarted = false
        gameOver = true
        for i in cards.indices { cards[i].isLit = false }
        if score > highScore { highScore = score }
        showNameSheet = true
    }

    /// Schedules a light-up cycle. After the lit window the card turns off;
    /// if it was NOT tapped, the player loses a life. Then the next cycle starts.
    func scheduleNextLight(after delay: Double = 0) {
        let capturedGen    = generation
        let capturedWindow = level.litWindow

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard self.gameStarted && !self.gameOver else { return }
            guard self.generation == capturedGen else { return }

            // Remember which cards are about to be lit so we can check missed taps
            self.lightUpCards()
            let litCardIds = self.cards.filter { $0.isLit }.map { $0.id }

            // After the window, turn cards off and penalise missed taps
            DispatchQueue.main.asyncAfter(deadline: .now() + capturedWindow) {
                guard self.generation == capturedGen else { return }

                var missedAny = false
                for id in litCardIds {
                    if let idx = self.cards.firstIndex(where: { $0.id == id }),
                       self.cards[idx].isLit && !self.cards[idx].wasTapped {
                        // Card timed out without being tapped — lose a life
                        self.cards[idx].isLit = false
                        missedAny = true
                    }
                }

                if missedAny {
                    self.loseLife()
                }

                // Only continue if the game is still running
                guard self.gameStarted && !self.gameOver else { return }
                guard self.generation == capturedGen else { return }

                // 0.3 s gap between rounds
                self.scheduleNextLight(after: 0.3)
            }
        }
    }

    func lightUpCards() {
        guard !cards.isEmpty && gameStarted else { return }
        for i in cards.indices {
            cards[i].isLit = false
            cards[i].wasTapped = false
        }
        let shuffled = Array(0..<cards.count).shuffled()
        let count = min(level.litCount, cards.count)
        for i in 0..<count {
            cards[shuffled[i]].isLit = true
        }
    }

    func cardTapped(_ card: Card) {
        guard gameStarted && !gameOver else { return }
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        guard !cards[index].wasTapped else { return }

        if cards[index].isLit {
            score += 10
            withAnimation(.easeInOut(duration: 0.15)) {
                cards[index].isLit = false
            }
            cards[index].wasTapped = true
            // Check for score-based level progression after every correct tap
            checkLevelUp()
        } else {
            // Wrong tap — lose a life
            loseLife()
        }
    }

    /// Deducts one life and ends the game if lives reach 0.
    func loseLife() {
        guard lives > 0 else { return }
        lives -= 1

        // Visual flash
        lostLifeFlash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.lostLifeFlash = false
        }

        if lives == 0 {
            endGame()
        }
    }

    /// Level up based on score thresholds. When the level changes, bump
    /// generation so stale closures are discarded and restart the cycle.
    func checkLevelUp() {
        // Find the highest level whose threshold the player has met
        var targetLevel = 0
        for (i, lvl) in levels.enumerated() {
            if score >= lvl.scoreThreshold { targetLevel = i }
        }

        guard targetLevel != currentLevel else { return }
        currentLevel = targetLevel

        // Invalidate stale closures
        generation += 1
        cards = (0..<level.cardCount).map { Card(id: $0) }

        showLevelUp = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showLevelUp = false
        }

        // 0.8 s grace period after level-up
        scheduleNextLight(after: 0.8)
    }
}
