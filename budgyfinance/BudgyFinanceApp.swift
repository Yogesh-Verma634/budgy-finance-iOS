import SwiftUI
import Firebase

@main
struct BudgyFinanceApp: App {
    init() {
            FirebaseApp.configure() // Initialize Firebase
        }

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                StatsView()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar")
                    }

                CaptureView()
                    .tabItem {
                        Label("Scan", systemImage: "camera")
                    }

                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "clock")
                    }

                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            }
        }
    }
}
