import Foundation
import SwiftUI

// MARK: - App Error Types
enum AppError: LocalizedError, Equatable {
    // Network Errors
    case noInternetConnection
    case requestTimeout
    case serverError(String)
    
    // Receipt Processing Errors
    case imageProcessingFailed
    case ocrFailed
    case aiProcessingFailed
    case receiptParsingFailed
    
    // Firebase Errors
    case authenticationFailed
    case firestoreError(String)
    case dataNotFound
    
    // API Errors
    case invalidAPIKey
    case apiQuotaExceeded
    case apiError(String)
    
    // General Errors
    case unknownError
    case cameraNotAvailable
    case photoLibraryNotAvailable
    
    var errorDescription: String? {
        switch self {
        // Network Errors
        case .noInternetConnection:
            return "No internet connection. Please check your network and try again."
        case .requestTimeout:
            return "Request timed out. Please try again."
        case .serverError(let message):
            return "Server error: \(message)"
            
        // Receipt Processing Errors
        case .imageProcessingFailed:
            return "Unable to process the image. Please try taking a clearer photo."
        case .ocrFailed:
            return "Unable to read text from the receipt. Please ensure the receipt is clear and well-lit."
        case .aiProcessingFailed:
            return "Unable to process receipt data. Please try again or enter the receipt manually."
        case .receiptParsingFailed:
            return "Unable to extract receipt information. Please try again or enter the details manually."
            
        // Firebase Errors
        case .authenticationFailed:
            return "Authentication failed. Please sign in again."
        case .firestoreError(let message):
            return "Database error: \(message)"
        case .dataNotFound:
            return "No data found. Please try refreshing."
            
        // API Errors
        case .invalidAPIKey:
            return "Invalid API configuration. Please contact support."
        case .apiQuotaExceeded:
            return "Processing limit reached. Please try again later."
        case .apiError(let message):
            return "Service error: \(message)"
            
        // General Errors
        case .unknownError:
            return "An unexpected error occurred. Please try again."
        case .cameraNotAvailable:
            return "Camera is not available on this device."
        case .photoLibraryNotAvailable:
            return "Photo library access is not available."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noInternetConnection:
            return "Check your WiFi or cellular connection and try again."
        case .imageProcessingFailed, .ocrFailed:
            return "Try taking a new photo with better lighting and focus."
        case .aiProcessingFailed, .receiptParsingFailed:
            return "You can manually enter the receipt details instead."
        case .authenticationFailed:
            return "Please sign out and sign in again."
        case .apiQuotaExceeded:
            return "Wait a few minutes before trying again."
        case .invalidAPIKey:
            return "Contact app support for assistance."
        default:
            return "Please try again. If the problem persists, contact support."
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .noInternetConnection, .requestTimeout, .serverError, .aiProcessingFailed, .receiptParsingFailed:
            return true
        case .invalidAPIKey, .cameraNotAvailable, .photoLibraryNotAvailable, .authenticationFailed:
            return false
        default:
            return true
        }
    }
}

// MARK: - Error Alert Helper
extension AppError {
    func toAlertData() -> AlertData {
        return AlertData(
            title: "Error",
            message: self.localizedDescription,
            primaryButton: .default(Text("OK")),
            secondaryButton: self.isRetryable ? .default(Text("Retry")) : nil
        )
    }
}

// MARK: - Alert Data Structure
struct AlertData {
    let title: String
    let message: String
    let primaryButton: Alert.Button
    let secondaryButton: Alert.Button?
    
    func toAlert(retryAction: (() -> Void)? = nil) -> Alert {
        if let secondaryButton = secondaryButton, let retryAction = retryAction {
            return Alert(
                title: Text(title),
                message: Text(message),
                primaryButton: primaryButton,
                secondaryButton: .default(Text("Retry"), action: retryAction)
            )
        } else {
            return Alert(
                title: Text(title),
                message: Text(message),
                dismissButton: primaryButton
            )
        }
    }
}
