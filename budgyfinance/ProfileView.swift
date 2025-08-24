//
//  ProfileView.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 29/12/24.
//

import SwiftUI
import FirebaseAuth

// Import GlassmorphismBackground from HomeView

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
    @EnvironmentObject var firestoreManager: FirestoreManager
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var showChangePassword = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var showSecuritySettings = false
    @State private var showAppPreferences = false
    @State private var showDataManagement = false
    @State private var showHelpSupport = false
    @State private var showAbout = false

    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                GlassmorphismBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // User Profile Header
                        GlassmorphicProfileHeader(userEmail: authViewModel.currentUser?.email ?? "User")
                    
                        // Account Settings
                        GlassmorphicSettingsSection(
                            title: "Account Settings",
                            items: [
                                GlassmorphicSettingItem(
                                    icon: "lock.fill",
                                    title: "Change Password",
                                    subtitle: "Update your account password",
                                    action: { showChangePassword = true }
                                ),
                                GlassmorphicSettingItem(
                                    icon: "envelope.fill",
                                    title: "Email Settings",
                                    subtitle: authViewModel.currentUser?.email ?? "No email",
                                    action: { /* Email settings action */ }
                                ),
                                GlassmorphicSettingItem(
                                    icon: "bell.fill",
                                    title: "Notifications",
                                    subtitle: "Manage app notifications",
                                    action: { /* Notifications settings */ }
                                )
                            ]
                        )
                    
                        // App Settings
                        GlassmorphicSettingsSection(
                            title: "App Settings",
                            items: [
                                GlassmorphicSettingItem(
                                    icon: "gear.fill",
                                    title: "App Preferences",
                                    subtitle: "Customize your app experience",
                                    action: { showAppPreferences = true }
                                ),
                                GlassmorphicSettingItem(
                                    icon: "icloud.fill",
                                    title: "Data Management",
                                    subtitle: "Export, import, and manage your data",
                                    action: { showDataManagement = true }
                                ),
                                GlassmorphicSettingItem(
                                    icon: "shield.fill",
                                    title: "Privacy & Security",
                                    subtitle: "Privacy settings and security options",
                                    action: { showSecuritySettings = true }
                                )
                            ]
                        )
                    
                        // Support & Legal
                        GlassmorphicSettingsSection(
                            title: "Support & Legal",
                            items: [
                                GlassmorphicSettingItem(
                                    icon: "questionmark.circle.fill",
                                    title: "Help & Support",
                                    subtitle: "Get help and contact support",
                                    action: { showHelpSupport = true }
                                ),
                                GlassmorphicSettingItem(
                                    icon: "doc.text.fill",
                                    title: "Privacy Policy",
                                    subtitle: "Read our privacy policy",
                                    action: { showPrivacyPolicy = true }
                                ),
                                GlassmorphicSettingItem(
                                    icon: "doc.text.fill",
                                    title: "Terms of Service",
                                    subtitle: "Read our terms of service",
                                    action: { showTermsOfService = true }
                                ),
                                GlassmorphicSettingItem(
                                    icon: "info.circle.fill",
                                    title: "About",
                                    subtitle: "App version and information",
                                    action: { showAbout = true }
                                )
                            ]
                        )
                    
                        // Account Actions
                        GlassmorphicAccountActionsSection(
                            onLogout: { showLogoutAlert = true },
                            onDeleteAccount: { showDeleteAccountAlert = true }
                        )
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
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
        .sheet(isPresented: $showAppPreferences) {
            AppPreferencesView()
        }
        .sheet(isPresented: $showDataManagement) {
            DataManagementView()
        }
        .sheet(isPresented: $showHelpSupport) {
            HelpSupportView()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
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

// MARK: - Glassmorphic Components

// MARK: - Glassmorphic Profile Header
struct GlassmorphicProfileHeader: View {
    let userEmail: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile Image with glassmorphic background
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 12) {
                Text(userEmail)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                    
                    Text("Email Verified")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(.top, 20)
    }
}

// MARK: - Glassmorphic Settings Section
struct GlassmorphicSettingsSection: View {
    let title: String
    let items: [GlassmorphicSettingItem]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Section icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: getIconForSection(title))
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            
            VStack(spacing: 8) {
                ForEach(items, id: \.title) { item in
                    GlassmorphicSettingItemView(item: item)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
        .padding(.horizontal, 20)
    }
    
    private func getIconForSection(_ title: String) -> String {
        switch title {
        case "Account Settings": return "person.circle.fill"
        case "App Settings": return "gear.circle.fill"
        case "Support & Legal": return "questionmark.circle.fill"
        default: return "circle.fill"
        }
    }
}

// MARK: - Glassmorphic Setting Item
struct GlassmorphicSettingItem {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
}

// MARK: - Glassmorphic Setting Item View
struct GlassmorphicSettingItemView: View {
    let item: GlassmorphicSettingItem
    
    var body: some View {
        Button(action: item.action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Glassmorphic Account Actions Section
struct GlassmorphicAccountActionsSection: View {
    let onLogout: () -> Void
    let onDeleteAccount: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Account Actions")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Actions icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.red.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            
            VStack(spacing: 12) {
                // Logout Button
                Button(action: onLogout) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.2))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                                )
                            
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        
                        Text("Sign Out")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.orange.opacity(0.6))
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Delete Account Button
                Button(action: onDeleteAccount) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.2))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.red.opacity(0.4), lineWidth: 1)
                                )
                            
                            Image(systemName: "trash.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.red)
                        }
                        
                        Text("Delete Account")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.6))
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
        .padding(.horizontal, 20)
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
                    privacyPolicyContent
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
    
    private var privacyPolicyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy Policy for BudgyFinance")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Last updated: January 17, 2025")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Group {
                LegalSectionView(title: "Introduction") {
                    Text("BudgyFinance is committed to protecting your privacy. This policy explains how we collect, use, and safeguard your information.")
                }
                
                LegalSectionView(title: "Information We Collect") {
                    Text("**Personal Information:**")
                        .fontWeight(.semibold)
                    Text("• Account details (email, name)\n• Receipt images and extracted data\n• Budget and spending preferences")
                    
                    Text("**Automatically Collected:**")
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                    Text("• Device information and usage data\n• Error logs and performance metrics")
                }
                
                LegalSectionView(title: "How We Use Your Information") {
                    Text("• Process receipts using AI technology\n• Track spending and budget progress\n• Sync data across your devices\n• Provide customer support")
                }
                
                LegalSectionView(title: "Third-Party Services") {
                    Text("We use:")
                    Text("• **Firebase**: Secure data storage\n• **OpenAI**: Receipt text extraction\n• **Apple Services**: App Store integration")
                }
                
                LegalSectionView(title: "Data Security") {
                    Text("• All data encrypted during transmission\n• Enterprise-grade Firebase security\n• Limited access controls\n• Regular security updates")
                }
                
                LegalSectionView(title: "Your Rights") {
                    Text("• View and update your information\n• Delete your account and data\n• Export your data\n• Contact us with questions")
                }
                
                LegalSectionView(title: "Contact") {
                    Text("Questions? Email: support@budgyfinance.com")
                        .foregroundColor(.blue)
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
                    termsContent
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
    
    private var termsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Terms of Service for BudgyFinance")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Last updated: January 17, 2025")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Group {
                LegalSectionView(title: "Acceptance of Terms") {
                    Text("By using BudgyFinance, you agree to these Terms of Service. If you disagree, please do not use the app.")
                }
                
                LegalSectionView(title: "Description of Service") {
                    Text("BudgyFinance helps you:")
                    Text("• Track expenses by scanning receipts\n• Set and monitor budget goals\n• Categorize spending and analyze habits\n• Sync data across your devices")
                }
                
                LegalSectionView(title: "Eligibility") {
                    Text("• Must be at least 13 years old\n• Users under 18 need parental consent\n• Must provide accurate account information\n• Responsible for account security")
                }
                
                LegalSectionView(title: "Acceptable Use") {
                    Text("**Allowed:**")
                        .fontWeight(.semibold)
                    Text("• Personal expense tracking\n• Processing your own receipts\n• Managing personal financial data")
                    
                    Text("**Prohibited:**")
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                    Text("• Processing others' receipts without permission\n• Commercial use without authorization\n• Reverse engineering the app\n• Sharing account credentials")
                        .foregroundColor(.red)
                }
                
                LegalSectionView(title: "Financial Disclaimer") {
                    Text("⚠️ **Important Notice**")
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    Text("• Not financial advice or professional service\n• Processing may not be 100% accurate\n• Verify all extracted data\n• Consult professionals for financial planning")
                        .foregroundColor(.orange)
                }
                
                LegalSectionView(title: "Limitation of Liability") {
                    Text("Service provided \"AS IS\" without warranties. We are not liable for financial losses or indirect damages.")
                }
                
                LegalSectionView(title: "Contact") {
                    Text("Questions? Email: support@budgyfinance.com")
                        .foregroundColor(.blue)
                }
            }
            
            Divider()
                .padding(.vertical)
            
            Text("By using BudgyFinance, you agree to these Terms of Service.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .italic()
        }
    }
}

// MARK: - Legal Section Component
struct LegalSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            content
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
