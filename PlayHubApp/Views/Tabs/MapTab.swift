import SwiftUI
import MapKit

struct MapTab: View {
    @StateObject private var store = SessionStore.shared
    
    // Default position: Colombo 7 / NIBM (6.9159, 79.8639)
    @State private var position: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9159, longitude: 79.8639),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    ))
    
    var validSessions: [GameSession] {
        store.sessions.filter { $0.latitude != 0 && $0.longitude != 0 }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            // Map always shown, even if no valid sessions exist
            Map(position: $position) {
                ForEach(validSessions) { session in
                    Annotation("", coordinate: CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude)) {
                        VStack(spacing: 0) {
                            Text("\(session.mode.rawValue): \(session.score)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(session.mode.color)
                                .cornerRadius(8)
                            
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.caption)
                                .foregroundColor(session.mode.color)
                                .offset(y: -3)
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                if let latestSession = validSessions.last {
                    position = .region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: latestSession.latitude, longitude: latestSession.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))
                }
            }
            
            // Overlay title
            Text("GAME MAP")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .background(Color.black.opacity(0.85))
                .clipShape(Capsule())
                .padding(.top, 10)
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MapTab()
}
