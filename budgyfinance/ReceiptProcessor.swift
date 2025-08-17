import Vision
import FirebaseFirestore

class ReceiptProcessor {
    static func processImage(_ imageData: Data, forUser userId: String, completion: @escaping (Receipt?) -> Void) {
        guard let image = UIImage(data: imageData), let cgImage = image.cgImage else {
            print("Failed to convert image data to CGImage.")
            completion(nil)
            return
        }

        // Step 1: Perform OCR using Vision
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("OCR Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            // Combine recognized text
            let extractedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            print("Extracted Text: \(extractedText)")

            // Step 2: Send extracted text to GPT with retry mechanism
            sendToGPTWithRetry(extractedText, forUser: userId, maxRetries: 3, completion: completion)
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Vision OCR Error: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    private static func sendToGPTWithRetry(_ extractedText: String, forUser userId: String, maxRetries: Int, completion: @escaping (Receipt?) -> Void) {
        print("Processing receipt (attempt \(4 - maxRetries)/3)...")
        
        sendToGPT(extractedText, forUser: userId) { receipt in
            if let receipt = receipt {
                completion(receipt)
            } else if maxRetries > 1 {
                print("⚠️ Processing failed, retrying... (attempts remaining: \(maxRetries - 1))")
                // Wait a moment before retrying
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    sendToGPTWithRetry(extractedText, forUser: userId, maxRetries: maxRetries - 1, completion: completion)
                }
            } else {
                print("❌ All processing attempts failed")
                completion(nil)
            }
        }
    }

    private static func sendToGPT(_ extractedText: String, forUser userId: String, completion: @escaping (Receipt?) -> Void) {
        // TODO: Replace this with your actual OpenAI API key
        // IMPORTANT: Never commit your real API key to version control!
        
        // For development, you can temporarily uncomment and set your key here:
        // let apiKey = "sk-proj-your-actual-key-here"
        
        // For production, use environment variables or secure key management
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Refined prompt
        let payload: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "user",
                    "content": """
                    Extract receipt information from the following text and return ONLY valid JSON without any additional text, formatting, or explanations.

                    Receipt text:
                    \(extractedText)
                    
                    Return a JSON object with this exact structure (no extra fields, no comments):
                    {
                        "storeName": "store name here",
                        "date": "YYYY-MM-DD",
                        "items": [
                            {"name": "item name", "price": 0.00, "quantity": 1, "category": "category name"}
                        ],
                        "totalAmount": 0.00,
                        "taxAmount": 0.00,
                        "tipAmount": 0.00,
                        "category": "category name"
                    }
                    
                    Rules:
                    - Use only the categories: Food & Dining, Transportation, Shopping, Entertainment, Utilities, Healthcare, Education, Travel, Other
                    - Ensure all strings are properly quoted
                    - Use numbers for prices, quantities, and amounts (not strings)
                    - Do not include any text before or after the JSON
                    - Do not use line breaks or special characters in string values
                    - Ensure the JSON is valid and complete
                    - IMPORTANT: Complete the entire JSON response - do not cut off mid-sentence
                    - If you have many items, ensure you complete the items array with a closing ]
                    - Always end with the closing } brace
                    - Double-check that your JSON is complete and valid
                    """
                ]
            ],
            "max_tokens": 2000,  // Increased from 500 to ensure complete responses
            "temperature": 0.1  // Lower temperature for more consistent formatting
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
        } catch {
            print("Failed to serialize payload: \(error.localizedDescription)")
            completion(nil)
            return
        }

        // Perform API Request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Request Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No response data received")
                completion(nil)
                return
            }

            if let dataString = String(data: data, encoding: .utf8) {
                print("Raw OpenAI Response: \(dataString)")
                print("Response length: \(dataString.count) characters")
                
                // Check for common JSON issues
                if dataString.contains("\\n") {
                    print("⚠️ Response contains escaped newlines")
                }
                if dataString.contains("\\\"") {
                    print("⚠️ Response contains escaped quotes")
                }
                if dataString.contains("\\t") {
                    print("⚠️ Response contains escaped tabs")
                }
            }

            // Decode the response
            do {
                if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("✅ Successfully parsed OpenAI API response")
                    
                    if let choices = responseJSON["choices"] as? [[String: Any]] {
                        print("✅ Found \(choices.count) choices")
                        
                        if let message = choices.first?["message"] as? [String: Any] {
                            print("✅ Found message in first choice")
                            
                            if let content = message["content"] as? String {
                                print("✅ Successfully extracted content")
                                print("Content length: \(content.count) characters")
                                print("Content preview: \(String(content.prefix(100)))...")
                                
                                // Parse the returned JSON from OpenAI into Receipt
                                if var receipt = parseOpenAIResponse(content) {
                                    receipt.userId = userId // Associate the user ID with the receipt
                                    
                                    // Save the receipt using FirestoreManager
                                    FirestoreManager.shared.addReceipt(receipt, forUser: userId) { error in
                                        if let error = error {
                                            print("Error saving receipt via FirestoreManager: \(error.localizedDescription)")
                                            completion(nil)
                                        } else {
                                            print("Receipt saved successfully via FirestoreManager!")
                                            completion(receipt)
                                        }
                                    }
                                } else {
                                    print("❌ Failed to parse OpenAI response into Receipt.")
                                    print("Raw content that failed to parse: \(content)")
                                    completion(nil)
                                }
                            } else {
                                print("❌ Could not extract content from message")
                                print("Message structure: \(message)")
                                completion(nil)
                            }
                        } else {
                            print("❌ Could not find message in first choice")
                            print("First choice structure: \(choices.first ?? [:])")
                            completion(nil)
                        }
                    } else {
                        print("❌ Could not find choices in response")
                        print("Response structure: \(responseJSON)")
                        completion(nil)
                    }
                } else {
                    print("❌ Invalid JSON structure from OpenAI response.")
                    completion(nil)
                }
            } catch {
                print("❌ Error parsing OpenAI response JSON: \(error.localizedDescription)")
                print("Error details: \(error)")
                completion(nil)
            }
        }.resume()
    }

    private static func parseOpenAIResponse(_ content: String) -> Receipt? {
        print("Attempting to parse OpenAI response: \(content)")
        
        // Validate that the JSON response is complete
        if !isCompleteJSON(content) {
            print("❌ Incomplete JSON detected - response appears to be cut off")
            print("Response ends with: \(String(content.suffix(50)))")
            
            // Try to fix the incomplete JSON
            if let fixedContent = attemptJSONFix(content) {
                print("🔄 Attempting to parse fixed JSON...")
                return parseOpenAIResponse(fixedContent)
            }
            
            return nil
        }
        
        // Clean the content to fix common JSON formatting issues
        let cleanedContent = cleanJSONContent(content)
        print("Cleaned content: \(cleanedContent)")
        
        // Ensure the content is valid JSON
        guard let jsonData = cleanedContent.data(using: .utf8) else {
            print("Failed to convert cleaned content to Data.")
            return nil
        }

        do {
            // Decode JSON into a Receipt object
            let decoder = JSONDecoder()
            var decodedReceipt = try decoder.decode(Receipt.self, from: jsonData)
            
            // Set the scanned time to current time (when the receipt was processed)
            decodedReceipt.scannedTime = Date()
            
            print("Successfully decoded Receipt: \(decodedReceipt)")
            print("Set scannedTime to: \(decodedReceipt.scannedTime?.description ?? "nil")")
            return decodedReceipt
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Decoding error - missing key '\(key)': \(context.debugDescription)")
            print("Coding path: \(context.codingPath)")
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Decoding error - type mismatch for '\(type)': \(context.debugDescription)")
            print("Coding path: \(context.codingPath)")
        } catch DecodingError.valueNotFound(let type, let context) {
            print("Decoding error - value not found for '\(type)': \(context.debugDescription)")
            print("Coding path: \(context.codingPath)")
        } catch DecodingError.dataCorrupted(let context) {
            print("Decoding error - data corrupted: \(context.debugDescription)")
            print("Coding path: \(context.codingPath)")
        } catch {
            print("Failed to decode receipt: \(error.localizedDescription)")
            print("Error details: \(error)")
        }

        // Fallback: Attempt to manually parse the JSON if decoding fails
        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                print("Manual parsing JSON: \(json)")
                
                let receipt = Receipt(
                    id: UUID().uuidString, // Always provide a non-nil id
                    storeName: json["storeName"] as? String,
                    date: json["date"] as? String,
                    totalAmount: json["totalAmount"] as? Double,
                    taxAmount: json["taxAmount"] as? Double,
                    tipAmount: json["tipAmount"] as? Double,
                    items: (json["items"] as? [[String: Any]])?.compactMap { item in
                        ReceiptItem(
                            id: UUID().uuidString, // Generate new ID for each item
                            name: item["name"] as? String,
                            price: item["price"] as? Double,
                            quantity: item["quantity"] as? Double,
                            category: item["category"] as? String
                        )
                    },
                    scannedTime: Date(), // Set current time as scanned time
                    userId: nil, // User ID will be added later
                    category: json["category"] as? String,
                    transactionDateTime: nil // Will be parsed from date field later
                )
                print("Manually Parsed Receipt: \(receipt)")
                return receipt
            }
        } catch {
            print("Manual parsing failed: \(error.localizedDescription)")
            print("Manual parsing error details: \(error)")
        }

        return nil
    }
    
    // Helper function to clean JSON content and fix common formatting issues
    private static func cleanJSONContent(_ content: String) -> String {
        var cleaned = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove any text before the first {
        if let startIndex = cleaned.firstIndex(of: "{") {
            cleaned = String(cleaned[startIndex...])
        }
        
        // Remove any text after the last }
        if let endIndex = cleaned.lastIndex(of: "}") {
            cleaned = String(cleaned[...endIndex])
        }
        
        // Fix common JSON formatting issues
        cleaned = cleaned.replacingOccurrences(of: "\\n", with: " ")
        cleaned = cleaned.replacingOccurrences(of: "\\t", with: " ")
        cleaned = cleaned.replacingOccurrences(of: "\\\"", with: "\"")
        
        // Remove any trailing commas before closing braces/brackets
        cleaned = cleaned.replacingOccurrences(of: ",}", with: "}")
        cleaned = cleaned.replacingOccurrences(of: ",]", with: "]")
        
        print("JSON cleaning applied. Original length: \(content.count), Cleaned length: \(cleaned.count)")
        
        return cleaned
    }
    
    // Helper function to validate JSON completeness
    private static func isCompleteJSON(_ content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if response starts and ends with braces
        guard trimmed.hasPrefix("{") && trimmed.hasSuffix("}") else {
            print("❌ JSON doesn't start with { or end with }")
            return false
        }
        
        // Count opening and closing braces to ensure they match
        let openBraces = trimmed.filter { $0 == "{" }.count
        let closeBraces = trimmed.filter { $0 == "}" }.count
        
        if openBraces != closeBraces {
            print("❌ Mismatched braces: \(openBraces) open, \(closeBraces) close")
            return false
        }
        
        // Check for incomplete items array (should end with ])
        if trimmed.contains("\"items\": [") {
            let itemsStart = trimmed.range(of: "\"items\": [")
            if let itemsStart = itemsStart {
                let afterItems = String(trimmed[itemsStart.upperBound...])
                if !afterItems.contains("]") {
                    print("❌ Items array appears to be incomplete")
                    return false
                }
            }
        }
        
        // Check for trailing commas before closing braces
        if trimmed.contains(",\n}") || trimmed.contains(",\n]") {
            print("❌ Trailing comma detected before closing brace/bracket")
            return false
        }
        
        print("✅ JSON appears to be complete")
        return true
    }
    
    // Helper function to attempt to fix incomplete JSON
    private static func attemptJSONFix(_ content: String) -> String? {
        print("🔧 Attempting to fix incomplete JSON...")
        
        var fixed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If it ends with a comma, remove it
        if fixed.hasSuffix(",") {
            fixed = String(fixed.dropLast())
        }
        
        // If items array is incomplete, try to close it
        if fixed.contains("\"items\": [") && !fixed.contains("]") {
            // Find the last incomplete item and close it
            if let lastComma = fixed.lastIndex(of: ",") {
                let beforeComma = String(fixed[..<lastComma])
                if beforeComma.contains("\"price\":") {
                    // Add missing fields and close the item
                    fixed = beforeComma + ", \"quantity\": 1, \"category\": \"Other\""
                }
            }
            fixed += "]"
        }
        
        // Add missing closing fields if they don't exist
        if !fixed.contains("\"totalAmount\":") {
            fixed = fixed.replacingOccurrences(of: "]", with: "], \"totalAmount\": 0.00")
        }
        if !fixed.contains("\"taxAmount\":") {
            fixed = fixed.replacingOccurrences(of: "\"totalAmount\":", with: "\"totalAmount\": 0.00, \"taxAmount\":")
        }
        if !fixed.contains("\"tipAmount\":") {
            fixed = fixed.replacingOccurrences(of: "\"taxAmount\":", with: "\"taxAmount\": 0.00, \"tipAmount\":")
        }
        if !fixed.contains("\"category\":") {
            fixed = fixed.replacingOccurrences(of: "\"tipAmount\":", with: "\"tipAmount\": 0.00, \"category\":")
        }
        
        // Ensure it ends with a closing brace
        if !fixed.hasSuffix("}") {
            fixed += "}"
        }
        
        // Validate the fixed JSON
        if isCompleteJSON(fixed) {
            print("✅ JSON fix successful")
            return fixed
        } else {
            print("❌ JSON fix failed")
            return nil
        }
    }
}
