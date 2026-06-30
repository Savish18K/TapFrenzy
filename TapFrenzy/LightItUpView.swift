import SwiftUI
import Combine

struct Level {
    let cardCount: Int
    let litWindow: Double
    let litCount: Int
    let color: Color
    let name: String
}

struct Card: Identifiable {
    let id: Int
    var isLit: Bool = false
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
    @State private var tickCount = 0
    @State private var playerName = ""
    @State private var showNameSheet = false
    
    
    
    let masterTimer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    let roundTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let levels = [
        Level(cardCount: 3, litWindow: 1.5, litCount: 1, color: .green,  name: "L1"),
        Level(cardCount: 4, litWindow: 1.2, litCount: 1, color: .blue,   name: "L2"),
        Level(cardCount: 6, litWindow: 1.0, litCount: 1, color: .yellow, name: "L3"),
        Level(cardCount: 9, litWindow: 0.8, litCount: 2, color: .red,    name: "L4")
    ]
    
    var level: Level {
        levels[currentLevel]
    }
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    }
    
    var ticksPerLight: Int {
        max(1, Int(level.litWindow / 0.4))
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
        .sheet(isPresented: $showNameSheet) {

            VStack(spacing:20){

                Text("Save Your Score")
                    .font(.largeTitle.bold())

                TextField("Enter your name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                Button("Save"){

                    let name = playerName.isEmpty ? "Player" : playerName

                    LeaderboardManager.shared.saveScore(
                        playerName: name,
                        score: score,
                        game: "LightItUp"
                    )

                    showNameSheet = false
                }
                .buttonStyle(.borderedProminent)

            }
            .padding()
        }
        .onReceive(roundTimer) { _ in
            guard gameStarted && !gameOver else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
                checkLevelUp()
            } else {
                endGame()
            }
        }
        .onReceive(masterTimer) { _ in
            guard gameStarted && !gameOver else { return }
            tickCount += 1
            
            if tickCount == ticksPerLight / 2 {
                for i in cards.indices {
                    cards[i].isLit = false
                }
            }
            
            if tickCount >= ticksPerLight {
                tickCount = 0
                lightUpCards()
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
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 1.5)
                    )
            }
        }
    }
    
    var gameScreen: some View {
        VStack(spacing: 0) {
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
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(cards) { card in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(card.isLit ? level.color : Color(red: 0.15, green: 0.17, blue: 0.22))
                        .frame(height: 100)
                        .scaleEffect(card.isLit ? 1.06 : 1.0)
                        .shadow(
                            color: card.isLit ? level.color.opacity(0.7) : .clear,
                            radius: 12
                        )
                        .animation(.easeInOut(duration: 0.2), value: card.isLit)
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
                HStack(spacing: 8) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 14))
                    Text("Choose Another Game")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 1.5)
                )
            }
        }
    }
    
    func startGame() {
        score = 0
        timeRemaining = 60
        gameOver = false
        currentLevel = 0
        tickCount = 0
        cards = (0..<levels[0].cardCount).map { Card(id: $0) }
        gameStarted = true
    }
    
    func endGame() {

        gameStarted = false
        gameOver = true

        for i in cards.indices {
            cards[i].isLit = false
        }

        if score > highScore {
            highScore = score
        }

        showNameSheet = true
    }
    
    
    func lightUpCards() {
        guard !cards.isEmpty && gameStarted else { return }
        for i in cards.indices {
            cards[i].isLit = false
        }
        let shuffled = Array(0..<cards.count).shuffled()
        let count = min(level.litCount, cards.count)
        for i in 0..<count {
            cards[shuffled[i]].isLit = true
        }
    }
    
    func cardTapped(_ card: Card) {
        guard gameStarted && !gameOver else { return }
        if card.isLit {
            score += 10
            if let index = cards.firstIndex(where: { $0.id == card.id }) {
                withAnimation {
                    cards[index].isLit = false
                }
            }
        } else {
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
            tickCount = 0
            cards = (0..<level.cardCount).map { Card(id: $0) }
            showLevelUp = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showLevelUp = false
            }
        }
    }
}
