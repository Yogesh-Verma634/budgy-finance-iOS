import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    // App information - these should match your actual app details
    private let appName = "BudgyFinance"
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    private let appDescription = "Smart Finance Management - Track expenses, manage budgets, and gain insights into your spending habits with AI-powered receipt scanning."
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App Icon and Info
                        VStack(spacing: 20) {
                            // App Icon
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                    )
                                
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            // App Details
                            VStack(spacing: 12) {
                                Text(appName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text(appDescription)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 8) {
                                    Text("Version \(appVersion) (\(buildNumber))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("© 2024 BudgyFinance. All rights reserved.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                        // App Features
                        AboutSection(title: "Key Features", icon: "star.fill", color: .yellow) {
                            VStack(spacing: 12) {
                                FeatureRow(icon: "camera.fill", text: "AI-powered receipt scanning")
                                FeatureRow(icon: "chart.bar.fill", text: "Smart spending analytics")
                                FeatureRow(icon: "creditcard.fill", text: "Budget management")
                                FeatureRow(icon: "icloud.fill", text: "Cloud data sync")
                                FeatureRow(icon: "shield.fill", text: "Bank-level security")
                            }
                        }
                        
                        // Technology
                        AboutSection(title: "Technology", icon: "gear.fill", color: .blue) {
                            VStack(spacing: 12) {
                                TechRow(icon: "brain.head.profile", text: "OpenAI GPT-4 for receipt processing")
                                TechRow(icon: "flame.fill", text: "Firebase for secure data storage")
                                TechRow(icon: "lock.shield.fill", text: "End-to-end encryption")
                                TechRow(icon: "network", text: "Real-time cloud synchronization")
                            }
                        }
                        
                        // Privacy & Security
                        AboutSection(title: "Privacy & Security", icon: "lock.fill", color: .green) {
                            VStack(spacing: 12) {
                                AboutPrivacyRow(icon: "checkmark.shield.fill", text: "GDPR compliant", color: .green)
                                AboutPrivacyRow(icon: "checkmark.shield.fill", text: "Your data never leaves secure servers", color: .green)
                                AboutPrivacyRow(icon: "checkmark.shield.fill", text: "No third-party data sharing", color: .green)
                                AboutPrivacyRow(icon: "checkmark.shield.fill", text: "Biometric authentication support", color: .green)
                            }
                        }
                        
                        // Support & Contact
                        AboutSection(title: "Support & Contact", icon: "envelope.fill", color: .purple) {
                            VStack(spacing: 16) {
                                VStack(spacing: 8) {
                                    Text("Need help? We're here for you")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                
                                    Button(action: {
                                        // Open email app
                                        if let url = URL(string: "mailto:support@budgyfinance.com") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "envelope")
                                            Text("support@budgyfinance.com")
                                        }
                                        .foregroundColor(.blue)
                                    }
                                }
                                
                                VStack(spacing: 8) {
                                    Text("Visit our website")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Button(action: {
                                        // Open website
                                        if let url = URL(string: "https://budgyfinance.com") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "globe")
                                            Text("budgyfinance.com")
                                        }
                                        .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                        
                        // Legal Information
                        AboutSection(title: "Legal Information", icon: "doc.text.fill", color: .orange) {
                            VStack(spacing: 12) {
                                LegalRow(icon: "doc.text.fill", text: "Privacy Policy", action: { /* Show privacy policy */ })
                                LegalRow(icon: "doc.text.fill", text: "Terms of Service", action: { /* Show terms */ })
                                LegalRow(icon: "doc.text.fill", text: "Data Processing Agreement", action: { /* Show DPA */ })
                                LegalRow(icon: "doc.text.fill", text: "Cookie Policy", action: { /* Show cookie policy */ })
                            }
                        }
                        
                        // App Store Information
                        AboutSection(title: "App Store", icon: "app.store.fill", color: .red) {
                            VStack(spacing: 12) {
                                VStack(spacing: 8) {
                                    Text("Rate BudgyFinance")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("If you enjoy using our app, please consider rating it on the App Store")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                
                                Button(action: {
                                    // Open App Store rating
                                    if let url = URL(string: "https://apps.apple.com/app/budgyfinance/id1234567890") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "star.fill")
                                        Text("Rate on App Store")
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.blue)
                                    )
                                }
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct AboutSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.yellow)
                .frame(width: 16)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct TechRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 16)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct AboutPrivacyRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct LegalRow: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .frame(width: 16)
                
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AboutView()
}
