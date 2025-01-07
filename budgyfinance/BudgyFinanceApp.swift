import SwiftUI
import Firebase
import FirebaseAuth

@main
struct BudgyFinanceApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
                    .onAppear {
                        print("Navigating to MainTabView")
                    }
            } else {
                AuthView()
                    .environmentObject(authViewModel)
                    .onAppear {
                        print("Displaying AuthView")
                    }
            }
        }
    }
}
