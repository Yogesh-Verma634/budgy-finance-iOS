//
//  RegistrationView.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 29/12/24.
//


import SwiftUI
import FirebaseAuth

struct RegistrationView: View {
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

            Button("Register") {
                registerUser()
            }
            .padding()

            Text(errorMessage)
                .foregroundColor(.red)
                .padding()
        }
        .padding()
    }

    private func registerUser() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = "Registration successful!"
            }
        }
    }
}