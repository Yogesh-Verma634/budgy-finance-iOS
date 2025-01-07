//
//  MainTabView.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 29/12/24.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            CaptureView()
                .tabItem {
                    Label("Scan", systemImage: "camera.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
        .accentColor(.blue)
    }
}
