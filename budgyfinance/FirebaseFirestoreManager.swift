import Foundation
import Firebase
import FirebaseFirestore

struct ReceiptItem {
    var name: String
    var price: Double
    var quantity: Int

    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "price": price,
            "quantity": quantity
        ]
    }

    static func fromDictionary(_ dictionary: [String: Any]) -> ReceiptItem {
        return ReceiptItem(
            name: dictionary["name"] as? String ?? "",
            price: dictionary["price"] as? Double ?? 0.0,
            quantity: dictionary["quantity"] as? Int ?? 1
        )
    }
}

import Foundation

struct Receipt: Identifiable {
    var id: String = UUID().uuidString // Generate a unique ID if not provided
    var storeName: String
    var date: Date
    var totalAmount: Double
    var taxAmount: Double
    var tipAmount: Double
    var items: [ReceiptItem]

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "storeName": storeName,
            "date": date,
            "totalAmount": totalAmount,
            "taxAmount": taxAmount,
            "tipAmount": tipAmount,
            "items": items.map { $0.toDictionary() }
        ]
    }

    static func fromDictionary(_ dictionary: [String: Any]) -> Receipt {
        let itemsArray = dictionary["items"] as? [[String: Any]] ?? []
        let items = itemsArray.map { ReceiptItem.fromDictionary($0) }

        return Receipt(
            id: dictionary["id"] as? String ?? UUID().uuidString, // Use the ID from Firestore, or generate a new one
            storeName: dictionary["storeName"] as? String ?? "",
            date: (dictionary["date"] as? Timestamp)?.dateValue() ?? Date(),
            totalAmount: dictionary["totalAmount"] as? Double ?? 0.0,
            taxAmount: dictionary["taxAmount"] as? Double ?? 0.0,
            tipAmount: dictionary["tipAmount"] as? Double ?? 0.0,
            items: items
        )
    }
}

