//
//  MainTabView.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 29/12/24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var firestoreManager: FirestoreManager
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            CaptureButtonView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Capture")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("History")
                }
            
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.blue)
        .onAppear {
            // Ensure user is authenticated and verified
            if !authViewModel.isAuthenticated || !authViewModel.isEmailVerified {
                authViewModel.checkAuthState()
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
        .environmentObject(FirestoreManager.shared)
}
