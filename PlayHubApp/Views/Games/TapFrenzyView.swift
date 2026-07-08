import SwiftUI
import Combine
import CoreLocation

struct TapFrenzyView: View {
    
    @Environment(\.dismiss) var dismiss
    
    // high score
    @AppStorage("tapFrenzyHighScore") private var highScore = 0
    
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var gameStarted = false
    @State private var gameOver = false
    
    @State private var combo = 1
    @State private var lastTapTime = Date.distantPast
    
    @State private var buttonColor = Color.green
    @State private var isTrap = false
    
    @State private var offsetX = CGFloat(0)
    @State private var offsetY = CGFloat(0)
    
    @State private var bonusActive = false
    @State private var bonusUsed = false
    
    @State private var tapScale = CGFloat(1.0)
    @State private var playerName = ""
    @State private var showNameSheet = false
    
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let colorTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
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
        .navigationBarHidden(true)
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
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
                Text("Game Over!")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.green)
                Text("Your Score: \(score)")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.white)
                Text("Enter your name to save")
                    .foregroundColor(.gray)
                TextField("Your name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(.black)
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding(.horizontal, 30)
                Button {
                    let lat = LocationService.shared.lastLocation?.coordinate.latitude ?? 0.0
                    let lon = LocationService.shared.lastLocation?.coordinate.longitude ?? 0.0
                    SessionStore.shared.save(mode: .tapFrenzy, score: score, lat: lat, lon: lon, playerName: playerName.isEmpty ? "Anonymous" : playerName)
                    
                    playerName = ""
                    showNameSheet = false
                } label: {
                    Text("SAVE & CONTINUE")
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .padding(.horizontal, 30)
                }
            }
            .padding()
        }
        .presentationDetents([.medium])
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
                .padding(.horizontal, 30)
            
            if highScore > 0 {
                Text("Best: \(highScore)")
                    .foregroundColor(.yellow)
                    .font(.headline)
            }
            
            Button {
                startGame()
            } label: {
                Text("START")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.horizontal, 50)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .foregroundColor(.black)
                    .cornerRadius(14)
            }
            NavigationLink(destination: StatsTab(game: "TapFrenzy")) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("Leaderboard")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.green.opacity(0.2))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green, lineWidth: 1.5)
                )
                .padding(.horizontal, 40)
            }
            
            Button {
                dismiss()
            } label: {
                Text("Back to Home")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.green.opacity(0.3))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green, lineWidth: 1.5)
                        )
            }
        }
    }
    
    var gameScreen: some View {
        VStack(spacing: 0) {
            
            VStack(spacing: 6) {
                Text("SCORE")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("\(score)")
                    .font(.system(size: 70, weight: .black))
                    .foregroundColor(.white)
                
                if combo > 1 {
                    Text("x\(combo) COMBO")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                }
                
                if bonusActive {
                    Text("DOUBLE POINTS")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(Color.yellow)
                        .cornerRadius(8)
                }
            }
            .padding(.top, 80)
            
            Spacer()
            
            Button {
                handleTap()
                withAnimation(.easeOut(duration: 0.1)) {
                    tapScale = 0.88
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeIn(duration: 0.1)) {
                        tapScale = 1.0
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(buttonColor)
                        .frame(width: buttonSize, height: buttonSize)
                    Text("TAP!")
                        .font(.system(size: buttonSize * 0.25, weight: .black))
                        .foregroundColor(.white)
                }
            }
            .offset(x: offsetX, y: offsetY)
            .scaleEffect(tapScale)
            .animation(.easeInOut(duration: 0.3), value: offsetX)
            .animation(.easeInOut(duration: 0.3), value: offsetY)
            
            Spacer()
            
            VStack(spacing: 6) {
                if !bonusUsed {
                    Text("Bonus burst coming...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Circle().fill(Color.green).frame(width: 10, height: 10)
                        Text("Safe").font(.caption).foregroundColor(.gray)
                    }
                    HStack(spacing: 6) {
                        Circle().fill(Color.gray).frame(width: 10, height: 10)
                        Text("Trap").font(.caption).foregroundColor(.gray)
                    }
                }
                
                Text("TIME")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                
                Text("\(timeRemaining)s")
                    .font(.system(size: 70, weight: .black))
                    .foregroundColor(timeRemaining <= 3 ? .red : .white)
                    .scaleEffect(timeRemaining <= 3 ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: timeRemaining)
            }
            .padding(.bottom, 60)
        }
        .onReceive(gameTimer) { _ in
            guard gameStarted && !gameOver else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
        .onReceive(colorTimer) { _ in
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
            
            ShareLink(item: "I just scored \(score) on Tap Frenzy — beat that! 👆") {
                Text("SHARE SCORE")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            
            Button {
                startGame()
            } label: {
                Text("PLAY AGAIN")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.horizontal, 44)
                    .padding(.vertical, 14)
                    .background(Color.green)
                    .foregroundColor(.black)
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
                            colors: [Color.green.opacity(0.6), Color.teal.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green, lineWidth: 1.5)
                        )
                }
        }
    }
    
    func startGame() {
        score = 0
        timeRemaining = 10
        gameOver = false
        gameStarted = true
        combo = 1
        lastTapTime = Date.distantPast
        buttonColor = Color.green
        isTrap = false
        offsetX = 0
        offsetY = 0
        bonusActive = false
        bonusUsed = false
        tapScale = 1.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            activateBonusBurst()
        }
    }
    
    func endGame() {

        gameOver = true

        if score > highScore {
            highScore = score
        }
        
        showNameSheet = true
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
            if bonusActive {
                score += combo * 2
            } else {
                score += combo
            }
        }
    }
    
    func changeTrapColour() {
        let pick = Int.random(in: 0...2)
        if pick == 0 {
            buttonColor = Color.gray
            isTrap = true
        } else if pick == 1 {
            buttonColor = Color.green
            isTrap = false
        } else {
            buttonColor = Color.blue
            isTrap = false
        }
    }
    
    func moveButton() {
        withAnimation {
            offsetX = CGFloat.random(in: -100...100)
            offsetY = CGFloat.random(in: -80...80)
        }
    }
    
    func activateBonusBurst() {
        guard !bonusUsed && !gameOver else { return }
        bonusActive = true
        bonusUsed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            bonusActive = false
        }
    }
}
