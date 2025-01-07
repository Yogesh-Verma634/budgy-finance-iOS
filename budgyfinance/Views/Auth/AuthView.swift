import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLogin = true // Toggle between Login and Register

    var body: some View {
        VStack {
            Spacer()

            // Logo and Welcome Text
            VStack(spacing: 8) {
                Image("wallet.pass")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .padding(.bottom, 20)
                
                Text("Budgy")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Simplify your expenses, master your finances.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 40)

            // Input Fields
            VStack(spacing: 16) {
                TextField("Email", text: $authViewModel.email)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 1)

                SecureField("Password", text: $authViewModel.password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 1)
            }
            .padding(.horizontal, 30)

            // Action Button
            Button(action: {
                if isLogin {
                    authViewModel.login()
                } else {
                    authViewModel.register()
                }
            }) {
                Text(isLogin ? "Login" : "Register")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isLogin ? Color.blue : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)

            // Toggle Between Login and Register
            Button(action: {
                isLogin.toggle()
            }) {
                Text(isLogin ? "Don't have an account? Register" : "Already have an account? Login")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding()

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .alert(item: $authViewModel.alertMessage) { alert in
            Alert(
                title: Text("Error"),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
