//
//  SecuritySettingsView.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 29/12/24.
//

import SwiftUI
import LocalAuthentication

struct SecuritySettingsView: View {
    @StateObject private var securityService = SecurityService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showBiometricSetup = false
    @State private var showSessionTimeoutPicker = false
    @State private var selectedSessionTimeout: TimeInterval = 30 * 60
    @State private var showSecurityLogs = false
    
    private let sessionTimeoutOptions: [(String, TimeInterval)] = [
        ("5 minutes", 5 * 60),
        ("15 minutes", 15 * 60),
        ("30 minutes", 30 * 60),
        ("1 hour", 60 * 60),
        ("2 hours", 2 * 60 * 60),
        ("Never", 0)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Security Status Card
                    SecurityStatusCard()
                    
                    // Biometric Authentication
                    VStack(spacing: 16) {
                        SectionHeader(title: "Biometric Authentication")
                        
                        VStack(spacing: 1) {
                            HStack {
                                Image(systemName: biometricIcon)
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(biometricTitle)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Text(biometricSubtitle)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if securityService.isBiometricAvailable {
                                    Toggle("", isOn: $securityService.isBiometricEnabled)
                                        .onChange(of: securityService.isBiometricEnabled) { enabled in
                                            if enabled {
                                                showBiometricSetup = true
                                            } else {
                                                securityService.disableBiometricAuthentication()
                                            }
                                        }
                                } else {
                                    Text("Not Available")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5)
                        }
                    }
                    
                    // Session Management
                    VStack(spacing: 16) {
                        SectionHeader(title: "Session Management")
                        
                        VStack(spacing: 1) {
                            Button(action: {
                                showSessionTimeoutPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Session Timeout")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                        
                                        Text(sessionTimeoutText)
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                            .buttonStyle(PlainButtonStyle())
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5)
                        }
                    }
                    
                    // Security Logs
                    VStack(spacing: 16) {
                        SectionHeader(title: "Security & Privacy")
                        
                        VStack(spacing: 1) {
                            Button(action: {
                                showSecurityLogs = true
                            }) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Security Logs")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                        
                                        Text("View recent security events")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                            .buttonStyle(PlainButtonStyle())
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5)
                        }
                    }
                    
                    // Security Tips
                    VStack(spacing: 16) {
                        SectionHeader(title: "Security Tips")
                        
                        VStack(spacing: 12) {
                            SecurityTipCard(
                                icon: "lock.shield.fill",
                                title: "Strong Passwords",
                                description: "Use unique passwords with uppercase, lowercase, numbers, and special characters."
                            )
                            
                            SecurityTipCard(
                                icon: "envelope.badge.fill",
                                title: "Email Verification",
                                description: "Always verify your email address to secure your account."
                            )
                            
                            SecurityTipCard(
                                icon: "iphone.gen3",
                                title: "Biometric Security",
                                description: "Enable Face ID or Touch ID for quick and secure access."
                            )
                            
                            SecurityTipCard(
                                icon: "clock.badge.fill",
                                title: "Session Management",
                                description: "Set appropriate session timeouts to protect your data."
                            )
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Security Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showBiometricSetup) {
            BiometricSetupView(securityService: securityService)
        }
        .sheet(isPresented: $showSessionTimeoutPicker) {
            SessionTimeoutPickerView(
                selectedTimeout: $selectedSessionTimeout,
                options: sessionTimeoutOptions
            )
        }
        .sheet(isPresented: $showSecurityLogs) {
            SecurityLogsView()
        }
        .onAppear {
            selectedSessionTimeout = securityService.sessionTimeout
        }
        .onChange(of: selectedSessionTimeout) { newTimeout in
            securityService.sessionTimeout = newTimeout
            UserDefaults.standard.set(newTimeout, forKey: "sessionTimeout")
        }
    }
    
    private var biometricIcon: String {
        switch securityService.biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "person.badge.key"
        }
    }
    
    private var biometricTitle: String {
        switch securityService.biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Biometric Authentication"
        }
    }
    
    private var biometricSubtitle: String {
        if securityService.isBiometricAvailable {
            return securityService.isBiometricEnabled ? "Enabled" : "Disabled"
        } else {
            return "Not available on this device"
        }
    }
    
    private var sessionTimeoutText: String {
        if selectedSessionTimeout == 0 {
            return "Never"
        } else {
            let minutes = Int(selectedSessionTimeout / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s")"
        }
    }
}

// MARK: - Security Status Card
struct SecurityStatusCard: View {
    @StateObject private var securityService = SecurityService.shared
    @State private var securityStatus: AccountSecurityStatus = AccountSecurityStatus()
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Security Score")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("\(securityStatus.securityScore)/100")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(securityStatus.securityLevel)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(securityLevelColor)
                    
                    Text("Level")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            ProgressView(value: Double(securityStatus.securityScore), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: securityLevelColor))
                .frame(height: 8)
            
            // Security indicators
            HStack(spacing: 20) {
                SecurityIndicator(
                    icon: "checkmark.seal.fill",
                    title: "Email",
                    isActive: securityStatus.isEmailVerified,
                    color: .green
                )
                
                SecurityIndicator(
                    icon: "faceid",
                    title: "Biometric",
                    isActive: securityStatus.isBiometricEnabled,
                    color: .blue
                )
                
                SecurityIndicator(
                    icon: "clock.fill",
                    title: "Session",
                    isActive: securityStatus.sessionTimeoutMinutes <= 30,
                    color: .orange
                )
                
                SecurityIndicator(
                    icon: "shield.fill",
                    title: "Activity",
                    isActive: securityStatus.recentFailedLogins == 0,
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10)
        .onAppear {
            securityStatus = securityService.checkAccountSecurity()
        }
    }
    
    private var securityLevelColor: Color {
        switch securityStatus.securityLevel {
        case "Low": return .red
        case "Medium": return .orange
        case "Good": return .yellow
        case "Excellent": return .green
        default: return .gray
        }
    }
}

// MARK: - Security Indicator
struct SecurityIndicator: View {
    let icon: String
    let title: String
    let isActive: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isActive ? color : .gray)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isActive ? .primary : .secondary)
        }
    }
}

// MARK: - Security Tip Card
struct SecurityTipCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Biometric Setup View
struct BiometricSetupView: View {
    @ObservedObject var securityService: SecurityService
    @Environment(\.dismiss) private var dismiss
    @State private var isAuthenticating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Image(systemName: biometricIcon)
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Enable \(biometricTitle)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Use \(biometricTitle) to quickly and securely access your financial data.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(spacing: 16) {
                    Button("Enable \(biometricTitle)") {
                        isAuthenticating = true
                        securityService.authenticateWithBiometrics { success in
                            isAuthenticating = false
                            if success {
                                securityService.enableBiometricAuthentication()
                                dismiss()
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(isAuthenticating)
                    
                    Button("Not Now") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Setup \(biometricTitle)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var biometricIcon: String {
        switch securityService.biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "person.badge.key"
        }
    }
    
    private var biometricTitle: String {
        switch securityService.biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Biometric Authentication"
        }
    }
}

// MARK: - Session Timeout Picker View
struct SessionTimeoutPickerView: View {
    @Binding var selectedTimeout: TimeInterval
    let options: [(String, TimeInterval)]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Choose Session Timeout")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("How long should the app stay active before requiring re-authentication?")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                List {
                    ForEach(options, id: \.1) { option in
                        Button(action: {
                            selectedTimeout = option.1
                            dismiss()
                        }) {
                            HStack {
                                Text(option.0)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedTimeout == option.1 {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .padding()
            .navigationTitle("Session Timeout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Security Logs View
struct SecurityLogsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var securityLogs: [String] = []
    
    var body: some View {
        NavigationView {
            VStack {
                if securityLogs.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Security Events")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Security logs will appear here when events occur.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(securityLogs, id: \.self) { log in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(log)
                                    .font(.system(size: 14, design: .monospaced))
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Security Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            securityLogs = UserDefaults.standard.stringArray(forKey: "securityLogs") ?? []
        }
    }
}

#Preview {
    SecuritySettingsView()
} 