import SwiftUI
import Combine

struct HomeTab: View {
    private let challenge = DailyChallenge.today()
    @StateObject private var store = SessionStore.shared
    @AppStorage("profileImageData") private var profileImageData: Data = Data()
    
    @AppStorage("dismissedChallengeDate") private var dismissedChallengeDate: String = ""
    
    private var isChallengeDismissed: Bool {
        // Manually dismissed
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        if dismissedChallengeDate == todayStr {
            return true
        }
        
        // Or played today
        let today = Calendar.current.startOfDay(for: Date())
        let playedToday = store.sessions.contains { session in
            session.mode == challenge.gameMode &&
            Calendar.current.startOfDay(for: session.timestamp) == today
        }
        return playedToday
    }
    
    @ViewBuilder
    private func destinationForMode(_ mode: GameMode) -> some View {
        switch mode {
        case .tapFrenzy: TapFrenzyView()
        case .lightItUp: LightItUpView()
        case .quizRush: QuizRushView()
        }
    }
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 16) {
                
                // Header with title + profile icon
                HStack(alignment: .top) {
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 4) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.green, Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.bottom, 4)
                        
                        HStack(spacing: 0) {
                            Text("GAME")
                                .font(.system(size: 34, weight: .black))
                                .foregroundColor(.white)
                            Text(" ZONE")
                                .font(.system(size: 34, weight: .black))
                                .foregroundColor(.clear)
                                .overlay(
                                    LinearGradient(
                                        colors: [Color.green, Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .mask(
                                        Text(" ZONE")
                                            .font(.system(size: 34, weight: .black))
                                    )
                                )
                        }
                        
                        Text("Choose a game to play")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 34) // Balance the profile icon width
                    
                    Spacer()
                    
                    // Profile icon
                    NavigationLink(destination: ProfileView()) {
                        if !profileImageData.isEmpty, let uiImage = UIImage(data: profileImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(
                                        LinearGradient(
                                            colors: [Color.purple, Color.blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                                )
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.purple, Color.blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                
                // Daily Challenge Banner
                if !isChallengeDismissed {
                    ZStack(alignment: .topTrailing) {
                        NavigationLink(destination: destinationForMode(challenge.gameMode)) {
                            HStack(spacing: 14) {
                                Text(challenge.emoji)
                                    .font(.system(size: 36))
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("DAILY CHALLENGE")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(challenge.gameMode.color.opacity(0.9))
                                    Text(challenge.challengeText)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                                Text("PLAY")
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule().fill(challenge.gameMode.color)
                                    )
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(challenge.gameMode.color.opacity(0.12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(challenge.gameMode.color.opacity(0.5), lineWidth: 1.5)
                                    )
                            )
                        }
                        
                        // Dismiss button
                        Button(action: {
                            withAnimation {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd"
                                dismissedChallengeDate = formatter.string(from: Date())
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray.opacity(0.6))
                                .font(.system(size: 20))
                                .padding(6)
                                .offset(x: 8, y: -8)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Tap Frenzy button
                NavigationLink(destination: TapFrenzyView()) {
                    VStack(spacing: 10) {
                        Text("🔥")
                            .font(.system(size: 50))
                        Text("TAP FRENZY")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                        Text("Tap as fast as you can in 10 seconds")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green, lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, 24)
                
                // Light It Up button
                NavigationLink(destination: LightItUpView()) {
                    VStack(spacing: 10) {
                        Text("💡")
                            .font(.system(size: 50))
                        Text("LIGHT IT UP")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                        Text("Tap the lit card before it goes dark")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue, lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, 24)
                
                // Quiz Rush button
                NavigationLink(destination: QuizRushView()) {
                    VStack(spacing: 10) {
                        Text("🧠")
                            .font(.system(size: 50))
                        Text("QUIZ RUSH")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                        Text("Answer 10 trivia questions from a live API")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange, lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        HomeTab()
    }
}
