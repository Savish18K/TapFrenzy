import SwiftUI
import MapKit

struct MapTab: View {
    @StateObject private var store = SessionStore.shared
    
    // Default region (e.g. San Francisco)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    var validSessions: [GameSession] {
        store.sessions.filter { $0.latitude != 0 && $0.longitude != 0 }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if validSessions.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "map")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No Location Data")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Play a game with location enabled\nto see your sessions on the map.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
            } else {
                Map(coordinateRegion: $region, annotationItems: validSessions) { session in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude)) {
                        VStack(spacing: 0) {
                            Text("\(session.score)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(session.mode.color)
                                .cornerRadius(8)
                            
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.caption)
                                .foregroundColor(session.mode.color)
                                .offset(y: -2)
                        }
                    }
                }
                .ignoresSafeArea(edges: [.top, .horizontal])
                .onAppear {
                    if let first = validSessions.last {
                        region = MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude),
                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        )
                    }
                }
            }
        }
        .navigationTitle("Session Map")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MapTab()
}
