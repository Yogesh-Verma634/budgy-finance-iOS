//
//  SecurityService.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 29/12/24.
//

import Foundation
import LocalAuthentication
import FirebaseAuth
import Combine
import UIKit

class SecurityService: ObservableObject {
    static let shared = SecurityService()
    
    @Published var isBiometricEnabled = false
    @Published var isBiometricAvailable = false
    @Published var biometricType: LABiometryType = .none
    @Published var sessionTimeout: TimeInterval = 30 * 60 // 30 minutes
    @Published var lastActivityTime: Date = Date()
    
    private var cancellables = Set<AnyCancellable>()
    private let context = LAContext()
    
    private init() {
        checkBiometricAvailability()
        setupSessionMonitoring()
    }
    
    // MARK: - Biometric Authentication
    func checkBiometricAvailability() {
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isBiometricAvailable = true
            biometricType = context.biometryType
            
            // Check if user has enabled biometric auth
            isBiometricEnabled = UserDefaults.standard.bool(forKey: "biometricEnabled")
        } else {
            isBiometricAvailable = false
            biometricType = .none
            isBiometricEnabled = false
        }
    }
    
    func enableBiometricAuthentication() {
        guard isBiometricAvailable else { return }
        
        authenticateWithBiometrics { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.isBiometricEnabled = true
                    UserDefaults.standard.set(true, forKey: "biometricEnabled")
                    self?.logSecurityEvent("Biometric authentication enabled")
                }
            }
        }
    }
    
    func disableBiometricAuthentication() {
        isBiometricEnabled = false
        UserDefaults.standard.set(false, forKey: "biometricEnabled")
        logSecurityEvent("Biometric authentication disabled")
    }
    
    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        guard isBiometricAvailable else {
            completion(false)
            return
        }
        
        let reason = "Authenticate to access your financial data"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.updateLastActivity()
                    self.logSecurityEvent("Biometric authentication successful")
                } else {
                    self.logSecurityEvent("Biometric authentication failed: \(error?.localizedDescription ?? "Unknown error")")
                }
                completion(success)
            }
        }
    }
    
    // MARK: - Session Management
    private func setupSessionMonitoring() {
        // Monitor app state changes
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppBecameActive()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppWillResignActive()
            }
            .store(in: &cancellables)
        
        // Check session timeout periodically
        Timer.publish(every: 60, on: .main, in: .common) // Check every minute
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkSessionTimeout()
            }
            .store(in: &cancellables)
    }
    
    private func handleAppBecameActive() {
        if isBiometricEnabled && Auth.auth().currentUser != nil {
            let timeSinceLastActivity = Date().timeIntervalSince(lastActivityTime)
            
            if timeSinceLastActivity > sessionTimeout {
                // Session expired, require re-authentication
                authenticateWithBiometrics { success in
                    if !success {
                        // Force logout if biometric auth fails
                        self.forceLogout()
                    }
                }
            } else {
                updateLastActivity()
            }
        }
    }
    
    private func handleAppWillResignActive() {
        updateLastActivity()
    }
    
    private func checkSessionTimeout() {
        guard isBiometricEnabled && Auth.auth().currentUser != nil else { return }
        
        let timeSinceLastActivity = Date().timeIntervalSince(lastActivityTime)
        
        if timeSinceLastActivity > sessionTimeout {
            logSecurityEvent("Session timeout detected")
            forceLogout()
        }
    }
    
    private func updateLastActivity() {
        lastActivityTime = Date()
    }
    
    private func forceLogout() {
        do {
            try Auth.auth().signOut()
            logSecurityEvent("Forced logout due to security timeout")
        } catch {
            logSecurityEvent("Error during forced logout: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Security Logging
    func logSecurityEvent(_ event: String) {
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        let logEntry = "[\(timestamp)] SECURITY: \(event)"
        
        print(logEntry)
        
        // Store in UserDefaults for debugging (in production, send to secure logging service)
        var securityLogs = UserDefaults.standard.stringArray(forKey: "securityLogs") ?? []
        securityLogs.append(logEntry)
        
        // Keep only last 100 entries
        if securityLogs.count > 100 {
            securityLogs = Array(securityLogs.suffix(100))
        }
        
        UserDefaults.standard.set(securityLogs, forKey: "securityLogs")
    }
    
    // MARK: - Password Security
    func validatePasswordStrength(_ password: String) -> PasswordStrength {
        var score = 0
        var feedback: [String] = []
        
        // Length check
        if password.count >= 8 {
            score += 1
        } else {
            feedback.append("At least 8 characters")
        }
        
        // Uppercase check
        if password.range(of: "[A-Z]", options: .regularExpression) != nil {
            score += 1
        } else {
            feedback.append("At least one uppercase letter")
        }
        
        // Lowercase check
        if password.range(of: "[a-z]", options: .regularExpression) != nil {
            score += 1
        } else {
            feedback.append("At least one lowercase letter")
        }
        
        // Number check
        if password.range(of: "[0-9]", options: .regularExpression) != nil {
            score += 1
        } else {
            feedback.append("At least one number")
        }
        
        // Special character check
        if password.range(of: "[@$!%*?&]", options: .regularExpression) != nil {
            score += 1
        } else {
            feedback.append("At least one special character (@$!%*?&)")
        }
        
        // Common password check (simplified)
        let commonPasswords = ["password", "123456", "qwerty", "admin", "letmein"]
        if commonPasswords.contains(password.lowercased()) {
            score -= 2
            feedback.append("Avoid common passwords")
        }
        
        switch score {
        case 0...2:
            return PasswordStrength(level: .weak, score: score, feedback: feedback)
        case 3...4:
            return PasswordStrength(level: .medium, score: score, feedback: feedback)
        case 5...:
            return PasswordStrength(level: .strong, score: score, feedback: feedback)
        default:
            return PasswordStrength(level: .weak, score: score, feedback: feedback)
        }
    }
    
    // MARK: - Account Security
    func checkAccountSecurity() -> AccountSecurityStatus {
        var status = AccountSecurityStatus()
        
        // Check if email is verified
        if let user = Auth.auth().currentUser {
            status.isEmailVerified = user.isEmailVerified
            status.lastSignInDate = user.metadata.lastSignInDate
            status.accountCreationDate = user.metadata.creationDate
        }
        
        // Check if biometric is enabled
        status.isBiometricEnabled = isBiometricEnabled
        
        // Check session timeout
        status.sessionTimeoutMinutes = Int(sessionTimeout / 60)
        
        // Check for suspicious activity (simplified)
        let securityLogs = UserDefaults.standard.stringArray(forKey: "securityLogs") ?? []
        let recentFailedLogins = securityLogs.filter { log in
            log.contains("authentication failed") && 
            log.contains(DateFormatter.logFormatter.string(from: Date().addingTimeInterval(-24*60*60))) // Last 24 hours
        }.count
        
        status.recentFailedLogins = recentFailedLogins
        status.securityScore = calculateSecurityScore(status: status)
        
        return status
    }
    
    private func calculateSecurityScore(status: AccountSecurityStatus) -> Int {
        var score = 0
        
        if status.isEmailVerified { score += 25 }
        if status.isBiometricEnabled { score += 25 }
        if status.sessionTimeoutMinutes <= 30 { score += 25 }
        if status.recentFailedLogins == 0 { score += 25 }
        
        return min(score, 100)
    }
}

// MARK: - Supporting Types
struct PasswordStrength {
    enum Level {
        case weak, medium, strong
        
        var color: String {
            switch self {
            case .weak: return "red"
            case .medium: return "orange"
            case .strong: return "green"
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
    
    let level: Level
    let score: Int
    let feedback: [String]
}

struct AccountSecurityStatus {
    var isEmailVerified: Bool = false
    var isBiometricEnabled: Bool = false
    var sessionTimeoutMinutes: Int = 30
    var recentFailedLogins: Int = 0
    var lastSignInDate: Date?
    var accountCreationDate: Date?
    var securityScore: Int = 0
    
    var securityLevel: String {
        switch securityScore {
        case 0...25: return "Low"
        case 26...50: return "Medium"
        case 51...75: return "Good"
        case 76...100: return "Excellent"
        default: return "Unknown"
        }
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
} 