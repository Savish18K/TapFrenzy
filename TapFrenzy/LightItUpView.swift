import SwiftUI
import Combine
// card model
struct Card: Identifiable {
    let id: Int
    var isLit: Bool = false
}

// level system
struct Level {
    let cardCount: Int
    let litWindow: Double
    let litCount: Int
    let color: Color
    let name: String
}

struct LightItUpView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("lightItUpHighScore") private var highScore = 0
    
    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var gameStarted = false
    @State private var gameOver = false
    @State private var currentLevel = 0
    @State private var showLevelUp = false
    
    // timer for countdown
    let roundTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // timer for lighting up cards
    @State private var litTimer: Timer.TimerPublisher = Timer.publish(every: 1.5, on: .main, in: .common)
    @State private var litTimerConnection: Cancellable? = nil
    
    let levels = [
        Level(cardCount: 3, litWindow: 1.5, litCount: 1, color: .green,  name: "L1"),
        Level(cardCount: 4, litWindow: 1.2, litCount: 1, color: .blue,   name: "L2"),
        Level(cardCount: 6, litWindow: 1.0, litCount: 1, color: .yellow, name: "L3"),
        Level(cardCount: 9, litWindow: 0.8, litCount: 2, color: .red,    name: "L4")
    ]
    
    var level: Level {
        levels[currentLevel]
    }
    
    // grid columns
    var columns: [GridItem] {
        let cols = currentLevel < 2 ? 3 : 3
        return Array(repeating: GridItem(.flexible(), spacing: 12), count: cols)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if !gameStarted {
                startScreen
            } else if gameOver {
                gameOverScreen
            } else {
                gameScreen
            }
            
            // level up flash
            if showLevelUp {
                Color.white.opacity(0.15)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                
                Text("LEVEL UP!")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.white)
                    .allowsHitTesting(false)
            }
        }
        .navigationBarHidden(true)
        .onReceive(roundTimer) { _ in
            guard gameStarted && !gameOver else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
                checkLevelUp()
            } else {
                endGame()
            }
        }
    }
    
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
            
            VStack(spacing: 8) {
                Text("L1 → 3 cards  L2 → 4 cards")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("L3 → 6 cards  L4 → 9 cards (2 lit!)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Button {
                startGame()
            } label: {
                Text("START")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.horizontal, 50)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            
            Button {
                dismiss()
            } label: {
                Text("Back to Home")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
        }
    }
    
    var gameScreen: some View {
        VStack(spacing: 0) {
            
            // top bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SCORE")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(score)")
                        .font(.system(size: 38, weight: .black))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text(level.name)
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(level.color)
                    Text("LEVEL")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("TIME")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(timeRemaining)s")
                        .font(.system(size: 38, weight: .black))
                        .foregroundColor(timeRemaining <= 10 ? .red : .white)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            
            Spacer()
            
            // card grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(cards) { card in
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(card.isLit ? level.color : Color(red: 0.15, green: 0.17, blue: 0.22))
                            .frame(height: 100)
                            .scaleEffect(card.isLit ? 1.06 : 1.0)
                            .shadow(color: card.isLit ? level.color.opacity(0.7) : .clear, radius: 12)
                            .animation(.easeInOut(duration: 0.2), value: card.isLit)
                    }
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
    
    var gameOverScreen: some View {
        VStack(spacing: 24) {
            Text("TIME'S UP!")
                .font(.system(size: 40, weight: .black))
                .foregroundColor(.red)
            
            Text("Score")
                .foregroundColor(.gray)
            
            Text("\(score)")
                .font(.system(size: 70, weight: .black))
                .foregroundColor(.white)
            
            if score > 0 && score >= highScore {
                Text("NEW HIGH SCORE!")
                    .font(.headline)
                    .foregroundColor(.yellow)
            } else {
                Text("Best: \(highScore)")
                    .foregroundColor(.gray)
            }
            
            Button {
                startGame()
            } label: {
                Text("PLAY AGAIN")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.horizontal, 44)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            
            Button {
                dismiss()
            } label: {
                Text("Choose Another Game")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
        }
    }
    
    func startGame() {
        score = 0
        timeRemaining = 60
        gameOver = false
        gameStarted = true
        currentLevel = 0
        setupCards()
        startLitTimer()
    }
    
    func endGame() {
        gameOver = true
        litTimerConnection?.cancel()
        if score > highScore {
            highScore = score
        }
    }
    
    func setupCards() {
        cards = (0..<level.cardCount).map { Card(id: $0) }
    }
    
    func startLitTimer() {
        litTimerConnection?.cancel()
        litTimerConnection = Timer.publish(every: level.litWindow, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                guard gameStarted && !gameOver else { return }
                lightUpCards()
            }
    }
    
    func lightUpCards() {
        
        for i in cards.indices {
            cards[i].isLit = false
        }
        
        var indices = Array(0..<cards.count).shuffled()
        let count = min(level.litCount, cards.count)
        for i in 0..<count {
            cards[indices[i]].isLit = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + level.litWindow * 0.85) {
            for i in cards.indices {
                cards[i].isLit = false
            }
        }
    }
    
    func cardTapped(_ card: Card) {
        guard gameStarted && !gameOver else { return }
        
        if card.isLit {
            // correct tap
            withAnimation {
                score += 10
                if let index = cards.firstIndex(where: { $0.id == card.id }) {
                    cards[index].isLit = false
                }
            }
        } else {
            // wrong tap = penalty
            score = max(0, score - 5)
        }
    }
    
    func checkLevelUp() {
        let elapsed = 60 - timeRemaining
        var newLevel = 0
        
        if elapsed >= 45 {
            newLevel = 3
        } else if elapsed >= 30 {
            newLevel = 2
        } else if elapsed >= 15 {
            newLevel = 1
        } else {
            newLevel = 0
        }
        
        if newLevel != currentLevel {
            currentLevel = newLevel
            setupCards()
            startLitTimer()
            
            // show level up flash
            showLevelUp = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showLevelUp = false
            }
        }
    }
}
