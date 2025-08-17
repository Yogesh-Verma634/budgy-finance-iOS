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
    let type: AlertType
    
    enum AlertType {
        case error
        case success
        case warning
        case info
    }
}

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isEmailVerified = false
    @Published var isLoading = false
    @Published var alertMessage: AlertMessage?
    @Published var showAlert = false
    @Published var currentUser: User?
    @Published var authState: AuthState = .initial
    
    enum AuthState: Equatable {
        case initial
        case signingIn
        case signingUp
        case emailVerificationRequired
        case authenticated
        case signedOut
        case error(String)
        
        static func == (lhs: AuthState, rhs: AuthState) -> Bool {
            switch (lhs, rhs) {
            case (.initial, .initial),
                 (.signingIn, .signingIn),
                 (.signingUp, .signingUp),
                 (.emailVerificationRequired, .emailVerificationRequired),
                 (.authenticated, .authenticated):
                return true
            case (.error(let lhsMessage), .error(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthStateListener()
        checkAuthState()
    }
    
    private func setupAuthStateListener() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.currentUser = user
                    self?.isAuthenticated = user.isEmailVerified
                    self?.isEmailVerified = user.isEmailVerified
                    
                    if user.isEmailVerified {
                        self?.authState = .authenticated
                        print("User is signed in and verified: \(user.email ?? "Unknown")")
                    } else {
                        self?.authState = .emailVerificationRequired
                        print("User is signed in but email not verified: \(user.email ?? "Unknown")")
                    }
                } else {
                    self?.isAuthenticated = false
                    self?.isEmailVerified = false
                    self?.currentUser = nil
                    self?.authState = .signedOut
                    print("No user signed in")
                }
            }
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard validateEmail(email) else {
            showError("Please enter a valid email address")
            completion(false)
            return
        }
        
        guard !password.isEmpty else {
            showError("Please enter your password")
            completion(false)
            return
        }
        
        authState = .signingIn
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.handleAuthError(error)
                    completion(false)
                } else if let user = result?.user {
                    if user.isEmailVerified {
                        self?.authState = .authenticated
                        self?.showSuccess("Welcome back!")
                        completion(true)
                    } else {
                        self?.authState = .emailVerificationRequired
                        self?.showWarning("Please verify your email address to continue")
                        completion(false)
                    }
                }
            }
        }
    }
    
    // MARK: - Registration
    func register(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard validateEmail(email) else {
            showError("Please enter a valid email address")
            completion(false)
            return
        }
        
        guard validatePassword(password) else {
            showError("Password must be at least 8 characters with uppercase, lowercase, number, and special character")
            completion(false)
            return
        }
        
        authState = .signingUp
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.handleAuthError(error)
                    completion(false)
                } else if let user = result?.user {
                    self?.sendEmailVerification { success in
                        if success {
                            self?.authState = .emailVerificationRequired
                            self?.showSuccess("Account created! Please check your email to verify your account.")
                        } else {
                            self?.showError("Failed to send verification email. Please try again.")
                        }
                        completion(success)
                    }
                }
            }
        }
    }
    
    // MARK: - Email Verification
    func sendEmailVerification(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        user.sendEmailVerification { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError("Failed to send verification email: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func checkEmailVerification(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        user.reload { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError("Failed to check verification status: \(error.localizedDescription)")
                    completion(false)
                } else {
                    let isVerified = user.isEmailVerified
                    self?.isEmailVerified = isVerified
                    if isVerified {
                        self?.authState = .authenticated
                        self?.showSuccess("Email verified successfully!")
                    }
                    completion(isVerified)
                }
            }
        }
    }
    
    // MARK: - Password Reset
    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        guard validateEmail(email) else {
            showError("Please enter a valid email address")
            completion(false)
            return
        }
        
        isLoading = true
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.handleAuthError(error)
                    completion(false)
                } else {
                    self?.showSuccess("Password reset email sent! Please check your inbox.")
                    completion(true)
                }
            }
        }
    }
    
    // MARK: - Logout
    func logout() {
        do {
            try Auth.auth().signOut()
            authState = .initial
        } catch {
            showError("Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Validation
    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func validatePassword(_ password: String) -> Bool {
        // At least 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special character (any)
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z\\d])[A-Za-z\\d!@#$%^&*()_+-={}:;\"'<>,.?/\\|~`]{8,}$"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    // MARK: - Error Handling
    private func handleAuthError(_ error: Error) {
        let errorMessage: String
        
        switch error.localizedDescription {
        case let message where message.contains("no user record"):
            errorMessage = "No account found with this email address"
        case let message where message.contains("wrong password"):
            errorMessage = "Incorrect password. Please try again"
        case let message where message.contains("email already in use"):
            errorMessage = "An account with this email already exists"
        case let message where message.contains("weak password"):
            errorMessage = "Password is too weak. Please use a stronger password"
        case let message where message.contains("network"):
            errorMessage = "Network error. Please check your connection"
        default:
            errorMessage = error.localizedDescription
        }
        
        showError(errorMessage)
    }
    
    private func showError(_ message: String) {
        alertMessage = AlertMessage(message: message, type: .error)
        showAlert = true
    }
    
    private func showSuccess(_ message: String) {
        alertMessage = AlertMessage(message: message, type: .success)
        showAlert = true
    }
    
    private func showWarning(_ message: String) {
        alertMessage = AlertMessage(message: message, type: .warning)
        showAlert = true
    }
    
    private func showInfo(_ message: String) {
        alertMessage = AlertMessage(message: message, type: .info)
        showAlert = true
    }
    
    func checkAuthState() {
        if let currentUser = Auth.auth().currentUser {
            isAuthenticated = currentUser.isEmailVerified
            isEmailVerified = currentUser.isEmailVerified
            self.currentUser = currentUser
            
            if currentUser.isEmailVerified {
                authState = .authenticated
                print("User is signed in and verified: \(currentUser.email ?? "Unknown")")
            } else {
                authState = .emailVerificationRequired
                print("User is signed in but email not verified: \(currentUser.email ?? "Unknown")")
            }
        } else {
            isAuthenticated = false
            isEmailVerified = false
            currentUser = nil
            authState = .signedOut
            print("No user is signed in")
        }
    }
}
