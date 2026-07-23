import SwiftUI

// Central gradient background used across all screens.
struct AppBackground: View {
    var body: some View {
        ZStack {
            // Base: very dark navy
            Color(red: 0.05, green: 0.05, blue: 0.1)
                .ignoresSafeArea()

            // Layer 1: Deep purple glow — top left
            RadialGradient(
                colors: [
                    Color(red: 0.3, green: 0.0, blue: 0.5).opacity(0.6),
                    .clear
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            // Layer 2: Dark teal glow — top right
            RadialGradient(
                colors: [
                    Color(red: 0.0, green: 0.3, blue: 0.4).opacity(0.4),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 350
            )
            .ignoresSafeArea()

            // Layer 3: Dark ember glow — bottom right
            RadialGradient(
                colors: [
                    Color(red: 0.4, green: 0.1, blue: 0.0).opacity(0.3),
                    .clear
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()
        }
    }
}

#Preview {
    AppBackground()
}
