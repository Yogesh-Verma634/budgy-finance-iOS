//
//  ProfileView.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 25/12/24.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var userName: String = "Loading..."
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            // Display the user's name
            Text("Welcome, \(userName)")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding()

            Spacer()

            // Logout Button
            Button(action: {
                logout()
            }) {
                Text("Logout")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .onAppear(perform: loadUserName)
    }

    private func loadUserName() {
        // Retrieve the user's name or email
        if let user = Auth.auth().currentUser {
            userName = user.displayName ?? user.email ?? "User"
        } else {
            userName = "No User Found"
        }
    }

    private func logout() {
        do {
            try Auth.auth().signOut()
            presentationMode.wrappedValue.dismiss() // Dismiss the view

            // Navigate to AuthView
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = scene.windows.first {
//                    window.rootViewController = UIHostingController(rootView: AuthView(authViewModel: AuthViewModel()))
                    window.makeKeyAndVisible()
                }
            }
        } catch {
            print("Logout Error: \(error.localizedDescription)")
        }
    }
}
