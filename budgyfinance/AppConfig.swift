// 🔧 Application Configuration
// Centralized configuration for backend and processing options

import Foundation

struct AppConfig {
    
    // 🌐 Backend Configuration
    struct Backend {
        // Backend URLs loaded from environment variables only
        static var development: String {
            guard let url = ProcessInfo.processInfo.environment["BACKEND_DEV_URL"] else {
                fatalError("❌ BACKEND_DEV_URL environment variable not set")
            }
            return url
        }
        
        static var staging: String {
            guard let url = ProcessInfo.processInfo.environment["BACKEND_STAGING_URL"] else {
                fatalError("❌ BACKEND_STAGING_URL environment variable not set")
            }
            return url
        }
        
        static var production: String {
            guard let url = ProcessInfo.processInfo.environment["BACKEND_PROD_URL"] else {
                fatalError("❌ BACKEND_PROD_URL environment variable not set")
            }
            return url
        }
        
        // Current backend URL based on environment
        static var current: String {
            // Check for environment override first
            if let envBackendURL = ProcessInfo.processInfo.environment["BACKEND_URL"] {
                return envBackendURL
            }
            
            // Fallback to environment-specific URLs
            #if DEBUG
            return development
            #else
            return production
            #endif
        }
        
        // Safe getter that returns nil if environment variables aren't set
        static var safeCurrent: String? {
            // Check for environment override first
            if let envBackendURL = ProcessInfo.processInfo.environment["BACKEND_URL"] {
                return envBackendURL
            }
            
            // Try to get environment-specific URLs
            #if DEBUG
            return ProcessInfo.processInfo.environment["BACKEND_DEV_URL"]
            #else
            return ProcessInfo.processInfo.environment["BACKEND_PROD_URL"]
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
        guard let url = Backend.safeCurrent else {
            print("❌ No backend URL environment variables set")
            return nil
        }
        
        guard URL(string: url) != nil else {
            print("❌ Invalid backend URL: \(url)")
            return nil
        }
        return url
    }
    
    /// Get backend URL for specific environment
    static func getBackendURL(for environment: String) -> String? {
        let url: String
        switch environment.lowercased() {
        case "dev", "development":
            url = Backend.development
        case "staging":
            url = Backend.staging
        case "prod", "production":
            url = Backend.production
        default:
            url = Backend.current
        }
        
        guard URL(string: url) != nil else {
            print("❌ Invalid backend URL for \(environment): \(url)")
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
    
    /// Debug: Print current backend configuration
    static func debugBackendConfig() {
        print("🔧 Backend Configuration Debug:")
        print("   Environment: \(isDevelopment ? "Development" : "Production")")
        
        if let currentURL = Backend.safeCurrent {
            print("   Current URL: \(currentURL)")
        } else {
            print("   Current URL: ❌ Not set")
        }
        
        if let devURL = ProcessInfo.processInfo.environment["BACKEND_DEV_URL"] {
            print("   Dev URL: \(devURL)")
        } else {
            print("   Dev URL: ❌ Not set")
        }
        
        if let stagingURL = ProcessInfo.processInfo.environment["BACKEND_STAGING_URL"] {
            print("   Staging URL: \(stagingURL)")
        } else {
            print("   Staging URL: ❌ Not set")
        }
        
        if let prodURL = ProcessInfo.processInfo.environment["BACKEND_PROD_URL"] {
            print("   Production URL: \(prodURL)")
        } else {
            print("   Production URL: ❌ Not set")
        }
        
        if let envBackendURL = ProcessInfo.processInfo.environment["BACKEND_URL"] {
            print("   Environment Override: \(envBackendURL)")
        }
    }
    
    /// Get appropriate timeout for network requests
    static var networkTimeout: TimeInterval {
        return TimeInterval(Limits.requestTimeoutSeconds)
    }
}
