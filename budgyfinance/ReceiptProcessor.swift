import Vision
import FirebaseFirestore

class ReceiptProcessor {
    static func processImage(_ imageData: Data, completion: @escaping (Receipt?) -> Void) {
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

            // Step 2: Send extracted text to GPT
            sendToGPT(extractedText, completion: completion)
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Vision OCR Error: \(error.localizedDescription)")
            completion(nil)
        }
    }

    private static func sendToGPT(_ extractedText: String, completion: @escaping (Receipt?) -> Void) {
        let apiKey = ""

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
                    The following is the extracted text from a receipt:
                    \(extractedText)
                    
                    Please identify:
                    1. The store name
                    2. The date of purchase
                    3. The items purchased, including their names, prices, and quantities
                    4. The total amount
                    5. Any tax amount
                    6. Any tip amount
                    
                    Format your response as JSON with the following structure:
                    {
                        "storeName": "string",
                        "date": "YYYY-MM-DD",
                        "items": [
                            {"name": "string", "price": number, "quantity": number},
                            ...
                        ],
                        "totalAmount": number,
                        "taxAmount": number,
                        "tipAmount": number
                    }
                    """
                ]
            ],
            "max_tokens": 500
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
            }

            // Decode the response
            do {
                if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = responseJSON["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    print("Parsed OpenAI Response: \(content)")

                    // Parse the returned JSON from OpenAI into Receipt
                    if let receipt = parseOpenAIResponse(content) {
                        saveReceiptToFirestore(receipt)
                        completion(receipt)
                    } else {
                        print("Failed to parse OpenAI response into Receipt.")
                        completion(nil)
                    }
                } else {
                    print("Invalid JSON structure from OpenAI response.")
                    completion(nil)
                }
            } catch {
                print("Error parsing OpenAI response JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    private static func parseOpenAIResponse(_ content: String) -> Receipt? {
        // Ensure the content is valid JSON
        guard let jsonData = content.data(using: .utf8) else {
            print("Failed to convert content to Data.")
            return nil
        }

        do {
            // Decode JSON into a Receipt object
            let decoder = JSONDecoder()
            let decodedReceipt = try decoder.decode(Receipt.self, from: jsonData)
            print("Decoded Receipt: \(decodedReceipt)")
            return decodedReceipt
        } catch {
            print("Failed to decode receipt: \(error.localizedDescription)")
            print("Attempting to decode manually...")

            // Fallback: Attempt to manually parse the JSON if decoding fails
            do {
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    let receipt = Receipt(
                        id: UUID().uuidString,
                        storeName: json["storeName"] as? String,
                        date: json["date"] as? String,
                        totalAmount: json["totalAmount"] as? Double,
                        taxAmount: json["taxAmount"] as? Double,
                        tipAmount: json["tipAmount"] as? Double,
                        items: (json["items"] as? [[String: Any]])?.compactMap { item in
                            ReceiptItem(
                                name: item["name"] as? String,
                                price: item["price"] as? Double,
                                quantity: item["quantity"] as? Double
                            )
                        }
                    )
                    print("Manually Parsed Receipt: \(receipt)")
                    return receipt
                }
            } catch {
                print("Manual parsing failed: \(error.localizedDescription)")
            }

            return nil
        }
    }




    private static func saveReceiptToFirestore(_ receipt: Receipt) {
        let db = Firestore.firestore()
        
        // Safely handle optional items
        let itemsArray = receipt.items?.map { item in
            [
                "name": item.name ?? "Unknown Item",
                "price": item.price ?? 0.0,
                "quantity": item.quantity ?? 0.0
            ]
        } ?? []

        // Prepare the receipt data
        let receiptData: [String: Any] = [
            "storeName": receipt.storeName ?? "Unknown Store",
            "date": receipt.date ?? "Unknown Date",
            "totalAmount": receipt.totalAmount ?? 0.0,
            "taxAmount": receipt.taxAmount ?? 0.0,
            "tipAmount": receipt.tipAmount ?? 0.0,
            "items": itemsArray
        ]

        // Save to Firestore
        db.collection("receipts").document(receipt.id ?? "unknown").setData(receiptData) { error in
            if let error = error {
                print("Error saving receipt to Firestore: \(error.localizedDescription)")
            } else {
                print("Receipt saved successfully!")
            }
        }
    }

}
