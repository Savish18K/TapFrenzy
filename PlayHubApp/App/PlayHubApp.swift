//  PlayHubApp.swift

import SwiftUI

@main
struct PlayHubApp: App {
    init() {
        NotificationService.shared.requestPermission()
        _ = LocationService.shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
