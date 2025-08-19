// 🔐 Configuration Template
// Copy this file to Config.swift and add your keys
// Config.swift is ignored by git for security

import Foundation

struct AppConfig {
    // ⚠️ DO NOT commit real API keys to version control!
    
    // Option 1: Environment variables (recommended)
    static var openAIAPIKey: String? {
        return ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
    }
    
    // Option 2: iOS Keychain (for production)
    static func getSecureAPIKey() -> String? {
        // TODO: Implement keychain access
        return nil
    }
    
    // Option 3: User settings (let users provide their own key)
    static func getUserProvidedAPIKey() -> String? {
        return UserDefaults.standard.string(forKey: "user_openai_api_key")
    }
}

// Usage example:
// guard let apiKey = AppConfig.openAIAPIKey else {
//     print("API key not configured")
//     return
// }
