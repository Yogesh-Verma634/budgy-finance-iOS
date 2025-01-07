//
//  LoginView.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 29/12/24.
//


import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Login") {
                loginUser()
            }
            .padding()

            Text(errorMessage)
                .foregroundColor(.red)
                .padding()
        }
        .padding()
    }

    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = "Login successful!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if let window = UIApplication.shared.windows.first {
                        window.rootViewController = UIHostingController(rootView: MainTabView())
                        window.makeKeyAndVisible()
                    }
                }
            }
        }
    }
}
