import Vision
import UIKit

class ReceiptProcessor {
    static func processImage(_ image: UIImage, completion: @escaping (Receipt?) -> Void) {
        guard let cgImage = image.cgImage else { return }
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            var recognizedText = ""
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    recognizedText += topCandidate.string + "\n"
                }
            }

            // Parse the recognized text into a Receipt object
            let receipt = parseReceiptText(recognizedText)
            completion(receipt)
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }

    private static func parseReceiptText(_ text: String) -> Receipt? {
        // Implement receipt parsing logic here
        var items: [ReceiptItem] = []
        var storeName = "Store"
        var totalAmount: Double = 0.0
        var taxAmount: Double = 0.0
        var tipAmount: Double = 0.0

        // Example logic for parsing (customize as needed)
        let lines = text.split(separator: "\n")
        for line in lines {
            let components = line.split(separator: " ")
            if components.contains("Total") {
                totalAmount = Double(components.last ?? "0") ?? 0.0
            } else {
                let name = components.dropLast().joined(separator: " ")
                let price = Double(components.last ?? "0") ?? 0.0
                items.append(ReceiptItem(name: name, price: price, quantity: 1))
            }
        }

        return Receipt(
            storeName: storeName,
            date: Date(),
            totalAmount: totalAmount,
            taxAmount: taxAmount,
            tipAmount: tipAmount,
            items: items
        )
    }
}
