import SwiftUI
import Combine

struct ContentView: View {
    
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 10
    
    @State private var gameStarted: Bool = false
    @State private var gameOver: Bool = false
    @State private var highScore: Int = 0
    
    
    @State private var combo: Int = 1
    @State private var lastTapTime: Date = .distantPast
    
    @State private var buttonColor: Color = .green
    @State private var isTrap: Bool = false
    
    
    @State private var buttonOffset: CGSize = .zero
    
    
    @State private var bonusActive: Bool = false
    @State private var bonusUsed: Bool = false
    
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    let trapTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    
    let moveTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    
    var buttonSize: CGFloat {
        let fraction = CGFloat(timeRemaining) / 10.0
        return max(60, 180 * fraction)
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
        }
    }
        
        func startGame() {
            score = 0
            timeRemaining = 10
            gameOver = false
            gameStarted = true
            combo = 1
            lastTapTime = .distantPast
            buttonColor = .green
            isTrap = false
            buttonOffset = .zero
            bonusActive = false
            bonusUsed = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                activateBonusBurst()
            }
        }
        
        func endGame() {
            gameOver = true
            if score > highScore {
                highScore = score
            }
        }
        
        func handleTap() {
            guard gameStarted && !gameOver else { return }
            
            let now = Date()
            if now.timeIntervalSince(lastTapTime) < 0.5 {
                combo += 1
            } else {
                combo = 1
            }
            lastTapTime = now
            
            if isTrap {
                score = max(0, score - combo)
            } else {
                let multiplier = bonusActive ? 2 : 1
                score += combo * multiplier
            }
        }
        
        func changeTrapColour() {
            let pick = Int.random(in: 0...2)
            if pick == 0 {
                buttonColor = .gray
                isTrap = true
            } else if pick == 1 {
                buttonColor = .green
                isTrap = false
            } else {
                buttonColor = .blue
                isTrap = false
            }
        }
        
        func moveButton() {
            withAnimation {
                buttonOffset = CGSize(
                    width: CGFloat.random(in: -100...100),
                    height: CGFloat.random(in: -80...80)
                )
            }
        }
        
        func activateBonusBurst() {
            guard !bonusUsed && !gameOver else { return }
            bonusActive=true
            bonusUsed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                bonusActive = false
            }
        }
    
    
    var startScreen: some View {
        VStack(spacing: 30) {
            Text("TAP FRENZY")
                .font(.system(size: 42, weight: .black))
                .foregroundColor(.green)
            
            Text("Tap as fast as you can\nin 10 seconds!")
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.title3)
            
            if highScore > 0 {
                Text("🏆 Best: \(highScore)")
                    .foregroundColor(.yellow)
                    .font(.headline)
            }
            
            Button("START") {
                startGame()
            }
            .font(.system(size: 22, weight: .bold))
            .padding(.horizontal, 50)
            .padding(.vertical, 16)
            .background(Color.green)
            .foregroundColor(.black)
            .clipShape(Capsule())
        }
    }
    
    
    var gameScreen: some View {
        VStack {
            // Top HUD
            HStack {
                VStack(alignment: .leading) {
                    Text("SCORE")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(score)")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Combo badge
                if combo > 1 {
                    VStack {
                        Text("COMBO")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("×\(combo)")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("TIME")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(timeRemaining)s")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(timeRemaining <= 3 ? .red : .white)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            // Bonus burst banner
            if bonusActive {
                Text("⚡ DOUBLE POINTS ⚡")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.yellow)
                    .cornerRadius(8)
            }
            
            Spacer()
            
            // The Tap Button
            Button(action: handleTap) {
                ZStack {
                    Circle()
                        .fill(buttonColor)
                        .frame(width: buttonSize, height: buttonSize)
                        .shadow(color: buttonColor.opacity(0.6), radius: 20)
                    
                    Text("TAP!")
                        .font(.system(size: buttonSize * 0.22, weight: .black))
                        .foregroundColor(.white)
                }
            }
            .offset(buttonOffset)
            .animation(.spring(response: 0.4), value: buttonOffset)
            .disabled(gameOver)
            
            Spacer()
            
            // Bonus burst hint
            if !bonusUsed && !bonusActive {
                Text("⚡ Bonus burst coming....")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        
        .onReceive(timer) { _ in
            guard gameStarted && !gameOver else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
        .onReceive(trapTimer) { _ in
            guard gameStarted && !gameOver else { return }
            changeTrapColour()
        }
        .onReceive(moveTimer) { _ in
            guard gameStarted && !gameOver else { return }
            moveButton()
        }
    }
    
    
    var gameOverScreen: some View {
        VStack(spacing: 24) {
            Text("GAME OVER")
                .font(.system(size: 40, weight: .black))
                .foregroundColor(.red)
            
            Text("Score: \(score)")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
            
            if score >= highScore && score > 0 {
                Text("🏆 NEW HIGH SCORE!")
                    .font(.headline)
                    .foregroundColor(.yellow)
            } else {
                Text("Best: \(highScore)")
                    .foregroundColor(.gray)
            }
            
            Button("PLAY AGAIN") {
                startGame()
            }
            .font(.system(size: 20, weight: .bold))
            .padding(.horizontal, 44)
            .padding(.vertical, 14)
            .background(Color.green)
            .foregroundColor(.black)
            .clipShape(Capsule())
        }
    }
    
}
