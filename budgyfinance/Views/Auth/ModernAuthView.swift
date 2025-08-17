import SwiftUI
import FirebaseAuth

struct ModernAuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var isLoading = false
    @State private var animateBackground = false
    
    var body: some View {
        ZStack {
            // Animated background
            GeometryReader { geometry in
                ZStack {
                    // Primary gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.8),
                            Color.purple.opacity(0.6),
                            Color.blue.opacity(0.4)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Floating circles
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .offset(x: animateBackground ? 50 : -50, y: animateBackground ? -100 : 100)
                        .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animateBackground)
                    
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 150, height: 150)
                        .offset(x: animateBackground ? -100 : 100, y: animateBackground ? 50 : -50)
                        .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animateBackground)
                }
            }
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    Spacer(minLength: 60)
                    
                    // Header Section
                    VStack(spacing: 20) {
                        // Logo
                        AppIconView(size: 100, showGlow: true)
                        
                        VStack(spacing: 8) {
                            Text("Welcome to Budgy")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(isSignUp ? "Create your account" : "Sign in to continue")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    // Form Section
                    VStack(spacing: 20) {
                        // Email Field
                        ModernTextField(
                            text: $email,
                            placeholder: "Email address",
                            icon: "envelope.fill"
                        )
                        
                        // Password Field
                        ModernSecureField(
                            text: $password,
                            placeholder: "Password",
                            icon: "lock.fill",
                            showPassword: $showPassword
                        )
                        
                        // Confirm Password (Sign Up only)
                        if isSignUp {
                            ModernSecureField(
                                text: $confirmPassword,
                                placeholder: "Confirm password",
                                icon: "lock.fill",
                                showPassword: $showConfirmPassword
                            )
                        }
                        
                        // Forgot Password (Sign In only)
                        if !isSignUp {
                            HStack {
                                Spacer()
                                Button("Forgot password?") {
                                    // Handle forgot password
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        // Primary Action Button
                        Button(action: handlePrimaryAction) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text(isSignUp ? "Create Account" : "Sign In")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(isLoading || !isValidForm)
                        .opacity(isValidForm ? 1.0 : 0.6)
                        
                        // Toggle Sign In/Sign Up
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isSignUp.toggle()
                                email = ""
                                password = ""
                                confirmPassword = ""
                            }
                        }) {
                            HStack {
                                Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text(isSignUp ? "Sign In" : "Sign Up")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(isLoading)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animateBackground = true
            }
        }
        .alert("Error", isPresented: $authViewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(authViewModel.alertMessage?.message ?? "An error occurred")
        }
    }
    
    private var isValidForm: Bool {
        if isSignUp {
            return !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword && password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func handlePrimaryAction() {
        isLoading = true
        
        if isSignUp {
            authViewModel.register(email: email, password: password) { success in
                isLoading = false
                if success {
                    // Registration successful, user will be automatically signed in
                }
            }
        } else {
            authViewModel.login(email: email, password: password) { success in
                isLoading = false
                if success {
                    // Login successful
                }
            }
        }
    }
}

struct ModernTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16))
                .foregroundColor(.white)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.15))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ModernSecureField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    @Binding var showPassword: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 24)
            
            if showPassword {
                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            } else {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            
            Button(action: {
                showPassword.toggle()
            }) {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.15))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
} 