import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // Logo and Welcome Text
                VStack(spacing: 12) {
                    LogoView()
                    
                    Text("Welcome to Budgy")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Your personal finance companion.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 30)

                // Input Fields
                VStack(spacing: 16) {
                    CustomTextView(placeholder: "Email", text: $email)
                        .keyboardType(.emailAddress)
                    
                    CustomSecureField(placeholder: "Password", text: $password)
                }

                // Action Button
                Button(action: {
                    if isLogin {
                        authViewModel.login(email: email, password: password) { success in
                            if !success {
                                // Handle login failure if needed
                            }
                        }
                    } else {
                        authViewModel.register(email: email, password: password) { success in
                            if !success {
                                // Handle registration failure if needed
                            }
                        }
                    }
                }) {
                    Text(isLogin ? "Sign In" : "Create Account")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 10)

                // Toggle Between Login and Register
                Button(action: {
                    withAnimation {
                        isLogin.toggle()
                        email = ""
                        password = ""
                    }
                }) {
                    Text(isLogin ? "Don't have an account? Sign Up" : "Already have an account? Sign In")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 30)
        }
        .alert("Error", isPresented: $authViewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(authViewModel.alertMessage?.message ?? "An error occurred")
        }
    }
}
