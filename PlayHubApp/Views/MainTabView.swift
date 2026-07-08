import SwiftUI

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor.systemGray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        
        itemAppearance.selected.iconColor = UIColor.systemPurple
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemPurple]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        TabView {
            NavigationStack {
                HomeTab()
            }
            .tabItem {
                Label("Home", systemImage: "gamecontroller.fill")
            }
            
            NavigationStack {
                StatsTab()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            
            NavigationStack {
                MapTab()
            }
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }
            
            NavigationStack {
                SettingsTab()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .tint(.purple)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}
