//
//  AuthViewModel.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 29/12/24.
//

import FirebaseAuth
import Combine
import Foundation

struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var alertMessage: AlertMessage?
    @Published var isRegistering: Bool = false // New flag to manage registration flow

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthStateListener()
//        checkAuthState()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                if let email = user?.email {
                    print("User is signed in: \(email)")
                } else {
                    print("No user signed in")
                }
            }
        }
    }
    
    func login() {
        guard validateInputs() else { return }

        isLoading = true
        AuthService.shared.login(email: email, password: password)
            .sink { [weak self] completion in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                }
            } receiveValue: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isAuthenticated = true // Ensure this is set
                    print("User authenticated successfully")
                }
            }
            .store(in: &cancellables)
    }
    
    func register() {
        guard validateInputs() else { return }
        isRegistering = true // Set flag to true during registration
        
        isLoading = true
        AuthService.shared.register(email: email, password: password)
            .sink { [weak self] completion in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.alertMessage = AlertMessage(message: error.localizedDescription)
                        self?.isRegistering = false // Reset flag on failure
                    }
                }
            } receiveValue: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.alertMessage = AlertMessage(message:"Registration successful! Please log in.")
                    self?.logoutAfterRegistration()
                }
            }
            .store(in: &cancellables)
    }

    private func logoutAfterRegistration() {
        do {
            try Auth.auth().signOut()
            print("User logged out after registration")
            self.isAuthenticated = false
            self.isRegistering = false // Reset flag after sign out
        } catch {
            print("Error logging out after registration: \(error.localizedDescription)")
            self.isRegistering = false // Reset flag even on failure
        }
    }
    
    func logout() {
        AuthService.shared.logout()
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] _ in
                self?.clearFields()
            }
            .store(in: &cancellables)
    }
    
    private func validateInputs() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = AlertMessage(message: "Please fill in all fields")
            return false
        }
        return true
    }
    
    private func handleError(_ error: Error) {
        DispatchQueue.main.async {
            self.alertMessage = AlertMessage(message: error.localizedDescription)
        }
    }
    
    private func clearFields() {
        email = ""
        password = ""
        alertMessage = nil
    }
    
    func checkAuthState() {
        if let currentUser = Auth.auth().currentUser {
            isAuthenticated = true
            print("User is signed in: \(currentUser.email ?? "Unknown")")
        } else {
            isAuthenticated = false
            print("No user is signed in")
        }
    }
}
