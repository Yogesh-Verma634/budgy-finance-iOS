import SwiftUI

struct AppPreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("enableBiometrics") private var enableBiometrics = false
    @AppStorage("autoSyncData") private var autoSyncData = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("currencyFormat") private var currencyFormat = "USD"
    @AppStorage("dateFormat") private var dateFormat = "MM/dd/yyyy"
    
    private let currencies = ["USD", "EUR", "GBP", "CAD", "AUD", "JPY", "INR"]
    private let dateFormats = ["MM/dd/yyyy", "dd/MM/yyyy", "yyyy-MM-dd", "MMM dd, yyyy"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "gear.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("App Preferences")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Customize your BudgyFinance experience")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Notifications
                        PreferenceSection(title: "Notifications", icon: "bell.fill") {
                            VStack(spacing: 16) {
                                Toggle("Enable Push Notifications", isOn: $enableNotifications)
                                    .tint(.blue)
                                
                                if enableNotifications {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("You'll receive alerts for:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            PreferenceRow(icon: "exclamationmark.triangle.fill", text: "Budget limit warnings")
                                            PreferenceRow(icon: "chart.line.uptrend.xyaxis", text: "Weekly spending summaries")
                                            PreferenceRow(icon: "creditcard.fill", text: "Receipt processing updates")
                                        }
                                    }
                                    .padding(.leading, 20)
                                }
                            }
                        }
                        
                        // Security
                        PreferenceSection(title: "Security", icon: "lock.fill") {
                            VStack(spacing: 16) {
                                Toggle("Enable Biometric Authentication", isOn: $enableBiometrics)
                                    .tint(.green)
                                
                                if enableBiometrics {
                                    Text("Use Face ID or Touch ID to quickly access your app")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 20)
                                }
                            }
                        }
                        
                        // Data & Sync
                        PreferenceSection(title: "Data & Sync", icon: "icloud.fill") {
                            VStack(spacing: 16) {
                                Toggle("Auto-sync Data", isOn: $autoSyncData)
                                    .tint(.blue)
                                
                                if autoSyncData {
                                    Text("Automatically sync your data across devices")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 20)
                                }
                            }
                        }
                        
                        // Display
                        PreferenceSection(title: "Display", icon: "paintbrush.fill") {
                            VStack(spacing: 16) {
                                Toggle("Dark Mode", isOn: $darkModeEnabled)
                                    .tint(.purple)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Currency Format")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Picker("Currency", selection: $currencyFormat) {
                                        ForEach(currencies, id: \.self) { currency in
                                            Text(currency).tag(currency)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Date Format")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Picker("Date Format", selection: $dateFormat) {
                                        ForEach(dateFormats, id: \.self) { format in
                                            Text(format).tag(format)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Preferences")
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
struct PreferenceSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
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

struct PreferenceRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 16)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    AppPreferencesView()
}
