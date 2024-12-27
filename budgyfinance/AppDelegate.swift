//
//  AppDelegate.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 26/12/24.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Prepopulate DNS cache for Firestore
        prepopulateDNSCache(for: "firestore.googleapis.com")
        
        return true
    }
    
    // MARK: - DNS Pre-Caching Function
    private func prepopulateDNSCache(for hostName: String) {
        let host = CFHostCreateWithName(nil, hostName as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var resolved: DarwinBoolean = false
        if let addresses = CFHostGetAddressing(host, &resolved)?.takeUnretainedValue() as? [Data], resolved.boolValue {
            for address in addresses {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                address.withUnsafeBytes { ptr in
                    let sockaddrPtr = ptr.baseAddress!.assumingMemoryBound(to: sockaddr.self)
                    if getnameinfo(sockaddrPtr, socklen_t(address.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                        print("Prepopulated DNS Cache for: \(String(cString: hostname))")
                    }
                }
            }
        } else {
            print("Failed to resolve \(hostName)")
        }
    }
}
