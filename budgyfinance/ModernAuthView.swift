//
//  ModernAuthView.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 29/12/24.
//

import SwiftUI
import FirebaseAuth

struct ModernAuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUp = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showPasswordReset = false
    @State private var showEmailVerification = false
    @State private var passwordStrength: PasswordStrength = .weak
    @State private var isAnimating = false
    
    enum PasswordStrength {
        case weak, medium, strong
        
        var color: Color {
            switch self {
            case .weak: return .red
            case .medium: return .orange
            case .strong: return .green
            }
        }
        
        var text: String {
            switch self {
            case .weak: return "Weak"
            case .medium: return "Medium"
            case .strong: return "Strong"
            }
        }
    }
    
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
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            
            // Floating particles effect
            ForEach(0..<20) { index in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 2...6))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                        value: isAnimating
                    )
            }
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 60)
                    
                    // Logo and Title
                    VStack(spacing: 20) {
                        AppIconView(size: 80)
                            .shadow(color: .white.opacity(0.2), radius: 20)
                        
                        Text("BudgyFinance")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(isSignUp ? "Create your account" : "Welcome back")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Auth Form
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: 20)
                                
                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .foregroundColor(.white)
                                    .onChange(of: email) {
                                        validateEmail()
                                    }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            
                            if !email.isEmpty && !isValidEmail(email) {
                                Text("Please enter a valid email address")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: 20)
                                
                                if showPassword {
                                    TextField("Enter your password", text: $password)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(.white)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            
                            // Password strength indicator (only for sign up)
                            if isSignUp && !password.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Password strength:")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        Spacer()
                                        
                                        Text(passwordStrength.text)
                                            .font(.caption)
                                            .foregroundColor(passwordStrength.color)
                                            .fontWeight(.medium)
                                    }
                                    
                                    ProgressView(value: passwordStrengthValue)
                                        .progressViewStyle(LinearProgressViewStyle(tint: passwordStrength.color))
                                        .frame(height: 4)
                                }
                                .padding(.top, 4)
                            }
                        }
                        
                        // Confirm Password Field (only for sign up)
                        if isSignUp {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 20)
                                    
                                    if showConfirmPassword {
                                        TextField("Confirm your password", text: $confirmPassword)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .foregroundColor(.white)
                                    } else {
                                        SecureField("Confirm your password", text: $confirmPassword)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .foregroundColor(.white)
                                    }
                                    
                                    Button(action: {
                                        showConfirmPassword.toggle()
                                    }) {
                                        Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                
                                if !confirmPassword.isEmpty && password != confirmPassword {
                                    Text("Passwords do not match")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        // Forgot Password (only for sign in)
                        if !isSignUp {
                            HStack {
                                Spacer()
                                Button("Forgot Password?") {
                                    showPasswordReset = true
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        // Action Button
                        Button(action: {
                            handleAuthAction()
                        }) {
                            HStack {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text(isSignUp ? "Create Account" : "Sign In")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .foregroundColor(.white)
                        }
                        .disabled(authViewModel.isLoading || !isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.6)
                        
                        // Toggle between Sign In and Sign Up
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isSignUp.toggle()
                                email = ""
                                password = ""
                                confirmPassword = ""
                                showPassword = false
                                showConfirmPassword = false
                            }
                        }) {
                            Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .onChange(of: password) {
            if isSignUp {
                updatePasswordStrength()
            }
        }
        .onChange(of: confirmPassword) {
            // Trigger validation
        }
        .alert(isPresented: $authViewModel.showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(authViewModel.alertMessage?.message ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showPasswordReset) {
            PasswordResetView(authViewModel: authViewModel)
        }
        .sheet(isPresented: $showEmailVerification) {
            EmailVerificationView(authViewModel: authViewModel)
        }
        .onReceive(authViewModel.$authState) { state in
            if state == .emailVerificationRequired {
                showEmailVerification = true
            }
        }
    }
    
    private var alertTitle: String {
        switch authViewModel.alertMessage?.type {
        case .error: return "Error"
        case .success: return "Success"
        case .warning: return "Warning"
        case .info: return "Info"
        case .none: return "Alert"
        }
    }
    
    private var isFormValid: Bool {
        let emailValid = isValidEmail(email)
        let passwordValid = isSignUp ? password.count >= 8 : !password.isEmpty
        let confirmPasswordValid = isSignUp ? (password == confirmPassword && !confirmPassword.isEmpty) : true
        
        return emailValid && passwordValid && confirmPasswordValid
    }
    
    private var passwordStrengthValue: Double {
        switch passwordStrength {
        case .weak: return 0.33
        case .medium: return 0.66
        case .strong: return 1.0
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func validateEmail() {
        // Email validation is handled in real-time
    }
    
    private func updatePasswordStrength() {
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecial = password.range(of: "[@$!%*?&]", options: .regularExpression) != nil
        let isLongEnough = password.count >= 8
        
        let strength = [hasUppercase, hasLowercase, hasNumber, hasSpecial, isLongEnough].filter { $0 }.count
        
        switch strength {
        case 0...2:
            passwordStrength = .weak
        case 3...4:
            passwordStrength = .medium
        case 5:
            passwordStrength = .strong
        default:
            passwordStrength = .weak
        }
    }
    
    private func handleAuthAction() {
        if isSignUp {
            authViewModel.register(email: email, password: password) { success in
                if success {
                    // Registration successful, email verification will be handled
                }
            }
        } else {
            authViewModel.login(email: email, password: password) { success in
                if success {
                    // Login successful
                }
            }
        }
    }
}

// MARK: - Password Reset View
struct PasswordResetView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Reset Password")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Enter your email address and we'll send you a link to reset your password.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button("Send Reset Link") {
                        isLoading = true
                        authViewModel.resetPassword(email: email) { success in
                            isLoading = false
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(email.isEmpty || isLoading)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Password Reset")
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

// MARK: - Email Verification View
struct EmailVerificationView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isChecking = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Image(systemName: "envelope.badge")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Verify Your Email")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("We've sent a verification email to your inbox. Please check your email and click the verification link to continue.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(spacing: 20) {
                    Button("I've Verified My Email") {
                        isChecking = true
                        authViewModel.checkEmailVerification { isVerified in
                            isChecking = false
                            if isVerified {
                                dismiss()
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isChecking)
                    
                    Button("Resend Verification Email") {
                        authViewModel.sendEmailVerification { _ in
                            // Handle result
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isChecking)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Email Verification")
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

#Preview {
    ModernAuthView()
} 