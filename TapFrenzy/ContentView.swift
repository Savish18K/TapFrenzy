import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 40) {
                    
                    VStack(spacing: 8) {
                        Text("GAME")
                            .font(.system(size: 38, weight: .black))
                            .foregroundColor(.white)
                        Text(" Zone")
                            .font(.system(size: 38, weight: .black))
                            .foregroundColor(.clear)
                        overlay(
                            LinearGradient(
                                colors: [Color .green, Color.blue, Color.purple],
                                           startPoint: .leading,
                                endPoint: .trailing
                                          )
                            .mask(
                                   Text("Zone")
                                .font(.system(size: 38, weight: .black))
                                  )
                        )
                    }
                                               
                        Text("Choose a game to play")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 80)
                    
                    Spacer()
                    
                    // Tap Frenzy button
                    NavigationLink(destination: TapFrenzyView()) {
                        VStack(spacing: 10) {
                            Text("👆")
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
                        .padding(.vertical, 30)
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
                        .padding(.vertical, 30)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue, lineWidth: 1.5)
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
    ContentView()
}
