// 🔧 Application Configuration
// Centralized configuration for backend and processing options

import Foundation

struct AppConfig {
    
    // 🌐 Backend Configuration
    struct Backend {
        // Backend URLs for different environments
        static let development = "http://localhost:3000/api"
        static let staging = "https://budgyfinance-staging.herokuapp.com/api"
        static let production = "https://budgyfinance-backend.onrender.com/api"
        
        // Current backend URL based on build configuration
        static var current: String {
            #if DEBUG
            return production  // Use production backend even in debug for now
            #else
            return production
            #endif
        }
    }
    
    // 🔄 Processing Mode
    enum ProcessingMode {
        case backend      // Use secure backend (recommended)
        case direct       // Direct OpenAI calls (for development only)
    }
    
    // Current processing mode
    static var processingMode: ProcessingMode {
        // For now, always use backend for security
        // Can be made configurable later for advanced users
        return .backend
    }
    
    // 📊 Feature Flags
    struct Features {
        static let enableBackendProcessing = true
        static let enableQuotaTracking = true
        static let enableNetworkMonitoring = true
        static let enableCrashReporting = false // Set to true in production
        static let enableAnalytics = false      // Set to true in production
    }
    
    // 💰 Business Logic
    struct Limits {
        static let freeReceiptsPerMonth = 10
        static let maxImageSizeMB = 10
        static let maxReceiptItems = 50
        static let requestTimeoutSeconds = 30
    }
    
    // 🎨 UI Configuration
    struct UI {
        static let animationDuration = 0.3
        static let showProgressIndicators = true
        static let enableHapticFeedback = true
    }
    
    // 🔍 Debug Settings
    struct Debug {
        static let enableVerboseLogging = false
        static let showNetworkRequests = false
        static let enableTestMode = false
    }
}

// 🚀 Convenience functions
extension AppConfig {
    
    /// Get the current backend URL with validation
    static func getBackendURL() -> String? {
        let url = Backend.current
        guard URL(string: url) != nil else {
            print("❌ Invalid backend URL: \(url)")
            return nil
        }
        return url
    }
    
    /// Check if we're in development mode
    static var isDevelopment: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// Check if we're in production mode
    static var isProduction: Bool {
        return !isDevelopment
    }
    
    /// Get appropriate timeout for network requests
    static var networkTimeout: TimeInterval {
        return TimeInterval(Limits.requestTimeoutSeconds)
    }
}
