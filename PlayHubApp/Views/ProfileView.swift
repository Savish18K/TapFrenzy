import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("globalPlayerName") private var playerName = "Anonymous"
    @AppStorage("memberSinceDate") private var memberSinceTimestamp: Double = Date().timeIntervalSince1970
    @AppStorage("profileImageData") private var profileImageData: Data = Data()
    @StateObject private var store = SessionStore.shared
    
    @State private var selectedItem: PhotosPickerItem?
    
    private var memberSinceDate: Date {
        Date(timeIntervalSince1970: memberSinceTimestamp)
    }
    
    private var favoriteGame: GameMode {
        let counts = GameMode.allCases.map { (mode: $0, count: store.totalGames(for: $0)) }
        return counts.max(by: { $0.count < $1.count })?.mode ?? .tapFrenzy
    }
    
    private var memberSinceFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: memberSinceDate)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Background gradient blobs
            Circle()
                .fill(Color.purple.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -80, y: -250)
            
            Circle()
                .fill(Color.blue.opacity(0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: 120, y: 150)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer().frame(height: 60)
                    
                    // Avatar
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.4), Color.blue.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Circle().stroke(
                                        LinearGradient(
                                            colors: [Color.purple, Color.blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                                )
                            
                            if !profileImageData.isEmpty, let uiImage = UIImage(data: profileImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.purple, Color.blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            
                            // Edit badge
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.purple))
                                .offset(x: 40, y: 40)
                        }
                    }
                    .onChange(of: selectedItem) {
                        Task {
                            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                profileImageData = data
                            }
                        }
                    }
                    
                    // Title
                    Text("PROFILE")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    // Player Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PLAYER NAME")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Color.purple.opacity(0.8))
                        
                        HStack {
                            Image(systemName: "pencil")
                                .foregroundColor(.purple)
                            TextField("Enter your name", text: $playerName)
                                .foregroundColor(.white)
                                .font(.system(size: 17, weight: .semibold))
                                .colorScheme(.dark)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.purple.opacity(0.4), lineWidth: 1.5)
                                )
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Stats Cards
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            profileStatCard(
                                title: "GAMES PLAYED",
                                value: "\(store.totalGamesPlayed)",
                                icon: "gamecontroller.fill",
                                color: .green
                            )
                            profileStatCard(
                                title: "BEST SCORE",
                                value: "\(store.overallBestScore)",
                                icon: "trophy.fill",
                                color: .yellow
                            )
                        }
                        
                        HStack(spacing: 12) {
                            profileStatCard(
                                title: "FAVORITE GAME",
                                value: store.totalGamesPlayed > 0 ? favoriteGame.rawValue : "—",
                                icon: "heart.fill",
                                color: .pink
                            )
                            profileStatCard(
                                title: "MEMBER SINCE",
                                value: memberSinceFormatted,
                                icon: "calendar",
                                color: .cyan
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Per-game breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GAME BREAKDOWN")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 24)
                        
                        ForEach(GameMode.allCases) { mode in
                            HStack {
                                Circle()
                                    .fill(mode.color)
                                    .frame(width: 10, height: 10)
                                
                                Text(mode.rawValue)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(store.totalGames(for: mode)) games")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                
                                Text("Best: \(store.bestScore(for: mode))")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(mode.color)
                                    .frame(width: 80, alignment: .trailing)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Circle().fill(Color.white.opacity(0.14)))
                    .overlay(Circle().stroke(Color.white.opacity(0.22), lineWidth: 1))
            }
            .padding(.leading, 16)
            .padding(.top, 8)
        }
    }
    
    private func profileStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .black))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
