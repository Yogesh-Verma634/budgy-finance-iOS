import Foundation

struct Receipt: Codable, Identifiable {
    var id: String? // Document ID from Firestore
    var storeName: String?
    var date: String? // Keep as String for compatibility with OpenAI response
    var totalAmount: Double?
    var taxAmount: Double?
    var tipAmount: Double?
    var items: [ReceiptItem]?
}

struct ReceiptItem: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String?
    var price: Double?
    var quantity: Double?
}
