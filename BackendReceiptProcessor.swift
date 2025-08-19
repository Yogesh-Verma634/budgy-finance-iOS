// 🌐 Backend-Based Receipt Processor
// This version calls your secure backend instead of OpenAI directly

import UIKit
import Firebase
import FirebaseAuth

class BackendReceiptProcessor {
    
    // 🌐 Your backend API endpoint
    private static let backendURL = "https://your-backend.herokuapp.com/api" // Replace with your URL
    
    // 📱 Main processing function
    static func processImage(_ imageData: Data, forUser userId: String, completion: @escaping (Result<Receipt, AppError>) -> Void) {
        
        // Step 1: Check network connectivity
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.noInternetConnection))
            return
        }
        
        // Step 2: Extract text from image using Vision framework
        print("🔍 Extracting text from receipt image...")
        extractText(from: imageData) { textResult in
            switch textResult {
            case .success(let extractedText):
                print("✅ Text extracted: \(extractedText.prefix(100))...")
                
                // Step 3: Send to backend for AI processing
                sendToBackendAPI(extractedText, forUser: userId, completion: completion)
                
            case .failure(let error):
                print("❌ Text extraction failed: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // 🌐 Send to backend API (instead of OpenAI directly)
    private static func sendToBackendAPI(_ extractedText: String, forUser userId: String, completion: @escaping (Result<Receipt, AppError>) -> Void) {
        
        guard let url = URL(string: "\(backendURL)/process-receipt") else {
            completion(.failure(.unknown("Invalid backend URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 🔐 Add Firebase authentication token
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                print("❌ Failed to get auth token: \(error)")
                completion(.failure(.authenticationFailed))
                return
            }
            
            guard let token = token else {
                completion(.failure(.authenticationFailed))
                return
            }
            
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // 📦 Prepare request body
            let requestBody: [String: Any] = [
                "extractedText": extractedText,
                "userId": userId
            ]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            } catch {
                completion(.failure(.unknown("Failed to encode request")))
                return
            }
            
            print("🌐 Sending receipt to backend for processing...")
            
            // 🚀 Make the request
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    handleBackendResponse(data: data, response: response, error: error, completion: completion)
                }
            }.resume()
        }
    }
    
    // 📥 Handle backend response
    private static func handleBackendResponse(data: Data?, response: URLResponse?, error: Error?, completion: @escaping (Result<Receipt, AppError>) -> Void) {
        
        if let error = error {
            print("❌ Network error: \(error)")
            completion(.failure(.serverError(error.localizedDescription)))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(.serverError("Invalid response")))
            return
        }
        
        guard let data = data else {
            completion(.failure(.serverError("No data received")))
            return
        }
        
        print("📡 Backend responded with status: \(httpResponse.statusCode)")
        
        // Handle different status codes
        switch httpResponse.statusCode {
        case 200:
            // ✅ Success - parse receipt
            parseReceiptResponse(data: data, completion: completion)
            
        case 401:
            // 🔐 Authentication failed
            completion(.failure(.authenticationFailed))
            
        case 429:
            // 💰 Quota exceeded
            completion(.failure(.apiQuotaExceeded))
            
        case 400:
            // ❌ Bad request
            if let errorMessage = parseErrorMessage(data: data) {
                completion(.failure(.receiptParsingFailed))
            } else {
                completion(.failure(.unknown("Bad request")))
            }
            
        case 500...599:
            // 🏥 Server error
            completion(.failure(.serverError("Backend service unavailable")))
            
        default:
            completion(.failure(.serverError("Unexpected response: \(httpResponse.statusCode)")))
        }
    }
    
    // 📋 Parse successful receipt response
    private static func parseReceiptResponse(data: Data, completion: @escaping (Result<Receipt, AppError>) -> Void) {
        do {
            let receipt = try JSONDecoder().decode(Receipt.self, from: data)
            print("✅ Receipt parsed successfully: \(receipt.storeName ?? "Unknown store")")
            completion(.success(receipt))
            
        } catch {
            print("❌ Failed to parse receipt response: \(error)")
            
            // Try to parse error message from backend
            if let errorMessage = parseErrorMessage(data: data) {
                completion(.failure(.receiptParsingFailed))
            } else {
                completion(.failure(.receiptParsingFailed))
            }
        }
    }
    
    // 🚨 Parse error message from backend
    private static func parseErrorMessage(data: Data) -> String? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = json["error"] as? String {
                return error
            }
        } catch {
            print("Failed to parse error response")
        }
        return nil
    }
    
    // 👁️ Extract text using Vision framework (same as before)
    private static func extractText(from imageData: Data, completion: @escaping (Result<String, AppError>) -> Void) {
        guard let image = UIImage(data: imageData) else {
            completion(.failure(.imageProcessingFailed))
            return
        }
        
        guard let cgImage = image.cgImage else {
            completion(.failure(.imageProcessingFailed))
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("❌ Vision framework error: \(error)")
                completion(.failure(.ocrFailed))
                return
            }
            
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            if recognizedText.isEmpty {
                completion(.failure(.ocrFailed))
            } else {
                completion(.success(recognizedText))
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.ocrFailed))
                }
            }
        }
    }
}

// 🌐 Network monitoring
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published var isConnected = true
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}

// 📱 Usage in your app - replace the old ReceiptProcessor calls with:
/*
BackendReceiptProcessor.processImage(imageData, forUser: userId) { result in
    switch result {
    case .success(let receipt):
        // ✅ Receipt processed successfully
        print("Processed receipt: \(receipt.storeName ?? "Unknown")")
        
    case .failure(let error):
        // ❌ Handle error
        switch error {
        case .apiQuotaExceeded:
            // Show upgrade prompt
            showSubscriptionOffer()
        case .authenticationFailed:
            // Re-authenticate user
            showLoginScreen()
        default:
            // Show error message
            showError(error.localizedDescription)
        }
    }
}
*/
