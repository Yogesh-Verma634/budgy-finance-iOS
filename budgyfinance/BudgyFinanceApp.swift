//
//  BudgyFinanceApp.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 29/12/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct BudgyFinanceApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
        print("Firebase configured successfully")
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    switch authViewModel.authState {
                        case .initial: SplashScreenView()
                        case .signingIn, .signingUp: LoadingView()
                        case .emailVerificationRequired: EmailVerificationRequiredView()
                        case .authenticated: MainTabView().environmentObject(authViewModel)
                        case .signedOut: ModernAuthView().environmentObject(authViewModel)
                        case .error: ErrorView()
                    }
                }
            }
        }
    }
}

// MARK: - Splash Screen
struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var showMainContent = false
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.45),
                    Color(red: 0.2, green: 0.3, blue: 0.6),
                    Color(red: 0.3, green: 0.4, blue: 0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo with animation
                AppIconView(size: 120)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .shadow(color: .white.opacity(0.3), radius: 20)
                
                // App name
                Text("BudgyFinance")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                // Tagline
                Text("Smart Finance Management")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .opacity(isAnimating ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                isAnimating = true
            }
            
            // Auto-dismiss splash after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showMainContent = true
                }
            }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1.0 : 0.7)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Email Verification Required View
struct EmailVerificationRequiredView: View {
    @State private var showAuthView = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.45),
                    Color(red: 0.2, green: 0.3, blue: 0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Icon
                Image(systemName: "envelope.badge")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                // Title
                Text("Email Verification Required")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Message
                Text("Please verify your email address to access your account. Check your inbox for a verification link.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Buttons
                VStack(spacing: 16) {
                    Button("I've Verified My Email") {
                        // Handle verification
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button("Resend Verification Email") {
                        // Handle resending verification email
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Button("Sign In with Different Account") {
                        showAuthView = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showAuthView) {
            ModernAuthView()
        }
    }
}

// MARK: - Error View
struct ErrorView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Error icon
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                // Error message
                Text("Something went wrong")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Please try again later or contact support.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Retry button
                Button("Try Again") {
                    // Handle retry
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }
}

#Preview {
    ModernAuthView()
}
