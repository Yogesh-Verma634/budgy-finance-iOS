//
//  ProfileView.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 29/12/24.
//

import SwiftUI
import FirebaseAuth

// MARK: - Section Header Component
struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var showChangePassword = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var showSecuritySettings = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // User Profile Header
                    VStack(spacing: 16) {
                        // Profile Image
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 10)
                        
                        // User Info
                        VStack(spacing: 8) {
                            Text(authViewModel.currentUser?.email ?? "User")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                                
                                Text("Email Verified")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // Account Settings
                    VStack(spacing: 16) {
                        SectionHeader(title: "Account Settings")
                        
                        VStack(spacing: 1) {
                            ProfileMenuItem(
                                icon: "lock.fill",
                                title: "Change Password",
                                subtitle: "Update your account password"
                            ) {
                                showChangePassword = true
                            }
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            ProfileMenuItem(
                                icon: "envelope.fill",
                                title: "Email Settings",
                                subtitle: authViewModel.currentUser?.email ?? "No email"
                            ) {
                                // Email settings action
                            }
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            ProfileMenuItem(
                                icon: "bell.fill",
                                title: "Notifications",
                                subtitle: "Manage app notifications"
                            ) {
                                // Notifications settings
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                    }
                    
                    // App Settings
                    VStack(spacing: 16) {
                        SectionHeader(title: "App Settings")
                        
                        VStack(spacing: 1) {
                            ProfileMenuItem(
                                icon: "gear.fill",
                                title: "General Settings",
                                subtitle: "App preferences and configuration"
                            ) {
                                // General settings
                            }
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            ProfileMenuItem(
                                icon: "icloud.fill",
                                title: "Data & Storage",
                                subtitle: "Manage your data and storage"
                            ) {
                                // Data settings
                            }
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            ProfileMenuItem(
                                icon: "shield.fill",
                                title: "Privacy & Security",
                                subtitle: "Privacy settings and security options"
                            ) {
                                showSecuritySettings = true
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                    }
                    
                    // Support & Legal
                    VStack(spacing: 16) {
                        SectionHeader(title: "Support & Legal")
                        
                        VStack(spacing: 1) {
                            ProfileMenuItem(
                                icon: "questionmark.circle.fill",
                                title: "Help & Support",
                                subtitle: "Get help and contact support"
                            ) {
                                // Help action
                            }
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            ProfileMenuItem(
                                icon: "doc.text.fill",
                                title: "Privacy Policy",
                                subtitle: "Read our privacy policy"
                            ) {
                                showPrivacyPolicy = true
                            }
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            ProfileMenuItem(
                                icon: "doc.text.fill",
                                title: "Terms of Service",
                                subtitle: "Read our terms of service"
                            ) {
                                showTermsOfService = true
                            }
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            ProfileMenuItem(
                                icon: "info.circle.fill",
                                title: "About",
                                subtitle: "App version and information"
                            ) {
                                // About action
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                    }
                    
                    // Account Actions
                    VStack(spacing: 16) {
                        SectionHeader(title: "Account Actions")
                        
                        VStack(spacing: 12) {
                            // Logout Button
                            Button(action: {
                                showLogoutAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(.orange)
                                        .frame(width: 24)
                                    
                                    Text("Sign Out")
                                        .foregroundColor(.orange)
                                        .fontWeight(.medium)

            Spacer()
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 5)
                            }
                            
                            // Delete Account Button
            Button(action: {
                                showDeleteAccountAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                        .frame(width: 24)
                                    
                                    Text("Delete Account")
                                        .foregroundColor(.red)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                }
                    .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 5)
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Sign Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
        .sheet(isPresented: $showChangePassword) {
            ChangePasswordView(authViewModel: authViewModel)
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTermsOfService) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showSecuritySettings) {
            SecuritySettingsView()
        }
    }
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        user.delete { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error deleting account: \(error.localizedDescription)")
                } else {
                    authViewModel.logout()
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
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
    }
}

// MARK: - Change Password View
struct ChangePasswordView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showCurrentPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Change Password")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter your current password and choose a new one.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    // Current Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Password")
                            .font(.system(size: 16, weight: .medium))
                        
                        HStack {
                            if showCurrentPassword {
                                TextField("Enter current password", text: $currentPassword)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                SecureField("Enter current password", text: $currentPassword)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            Button(action: {
                                showCurrentPassword.toggle()
                            }) {
                                Image(systemName: showCurrentPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // New Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Password")
                            .font(.system(size: 16, weight: .medium))
                        
                        HStack {
                            if showNewPassword {
                                TextField("Enter new password", text: $newPassword)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                SecureField("Enter new password", text: $newPassword)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            Button(action: {
                                showNewPassword.toggle()
                            }) {
                                Image(systemName: showNewPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Confirm New Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm New Password")
                            .font(.system(size: 16, weight: .medium))
                        
                        HStack {
                            if showConfirmPassword {
                                TextField("Confirm new password", text: $confirmPassword)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
        } else {
                                SecureField("Confirm new password", text: $confirmPassword)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            Button(action: {
                                showConfirmPassword.toggle()
                            }) {
                                Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Button("Update Password") {
                    updatePassword()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isFormValid || isLoading)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Change Password")
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
    
    private var isFormValid: Bool {
        !currentPassword.isEmpty && 
        !newPassword.isEmpty && 
        !confirmPassword.isEmpty && 
        newPassword == confirmPassword &&
        newPassword.count >= 8
    }
    
    private func updatePassword() {
        // Implement password change logic
        // This would require re-authentication with current password
        // and then updating to new password
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Last updated: December 29, 2024")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Group {
                        Text("Information We Collect")
                            .font(.headline)
                        
                        Text("We collect information you provide directly to us, such as when you create an account, upload receipts, or contact us for support.")
                        
                        Text("How We Use Your Information")
                            .font(.headline)
                        
                        Text("We use the information we collect to provide, maintain, and improve our services, process transactions, and communicate with you.")
                        
                        Text("Data Security")
                            .font(.headline)
                        
                        Text("We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.")
                    }
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
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

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms of Service")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Last updated: December 29, 2024")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Group {
                        Text("Acceptance of Terms")
                            .font(.headline)
                        
                        Text("By accessing and using BudgyFinance, you accept and agree to be bound by the terms and provision of this agreement.")
                        
                        Text("Use License")
                            .font(.headline)
                        
                        Text("Permission is granted to temporarily download one copy of the app for personal, non-commercial transitory viewing only.")
                        
                        Text("Disclaimer")
                            .font(.headline)
                        
                        Text("The materials on BudgyFinance are provided on an 'as is' basis. BudgyFinance makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.")
                    }
                }
                .padding()
            }
            .navigationTitle("Terms of Service")
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

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
