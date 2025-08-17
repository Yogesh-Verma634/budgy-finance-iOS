import Foundation
import FirebaseFirestore

class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()
    @Published var receiptsCache: [Receipt] = []
    private let db = Firestore.firestore()

    func fetchReceipts(forUser userId: String, completion: @escaping (Result<[Receipt], Error>) -> Void) {
        print("FirestoreManager: Fetching receipts for user: \(userId)")
        
        // Check if userId is valid
        guard !userId.isEmpty else {
            print("FirestoreManager: Error - userId is empty")
            completion(.failure(NSError(domain: "FirestoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID is empty"])))
            return
        }
        
        db.collection("users").document(userId).collection("receipts")
            .getDocuments { snapshot, error in
            if let error = error {
                print("FirestoreManager: Error fetching receipts: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                print("FirestoreManager: No documents found")
                completion(.success([]))
                return
            }
            
            let receipts = documents.compactMap { doc in
                do {
                    let receipt = try doc.data(as: Receipt.self)
                    return receipt
                } catch {
                    print("FirestoreManager: Failed to decode document \(doc.documentID): \(error.localizedDescription)")
                    
                    // Try manual decoding as fallback
                    if let manualReceipt = self.manualDecodeReceipt(from: doc.data(), documentId: doc.documentID) {
                        return manualReceipt
                    }
                    
                    return nil
                }
            }
            
            print("FirestoreManager: Successfully decoded \(receipts.count) receipts out of \(documents.count) documents")
            
            // Sort receipts by transaction date and time (most recent first) after fetching
            let sortedReceipts = receipts.sorted { (receipt1, receipt2) in
                let date1 = receipt1.parsedTransactionDateTime ?? receipt1.parsedReceiptDate ?? receipt1.scannedTime ?? Date.distantPast
                let date2 = receipt2.parsedTransactionDateTime ?? receipt2.parsedReceiptDate ?? receipt2.scannedTime ?? Date.distantPast
                return date1 > date2
            }
            
            DispatchQueue.main.async {
                self.receiptsCache = sortedReceipts
            }
            completion(.success(sortedReceipts))
        }
    }
    
    // Fallback manual decoding method
    private func manualDecodeReceipt(from data: [String: Any], documentId: String) -> Receipt? {
        let storeName = data["storeName"] as? String
        let date = data["date"] as? String
        let totalAmount = data["totalAmount"] as? Double
        let taxAmount = data["taxAmount"] as? Double
        let tipAmount = data["tipAmount"] as? Double
        let userId = data["userId"] as? String
        let category = data["category"] as? String
        
        // Handle scannedTime - could be Timestamp or Date
        var scannedTime: Date?
        if let timestamp = data["scannedTime"] as? Timestamp {
            scannedTime = timestamp.dateValue()
        } else if let dateValue = data["scannedTime"] as? Date {
            scannedTime = dateValue
        }
        
        // Handle transactionDateTime - could be Timestamp or Date
        var transactionDateTime: Date?
        if let timestamp = data["transactionDateTime"] as? Timestamp {
            transactionDateTime = timestamp.dateValue()
        } else if let dateValue = data["transactionDateTime"] as? Date {
            transactionDateTime = dateValue
        }
        
        // Handle items array
        var items: [ReceiptItem]?
        if let itemsData = data["items"] as? [[String: Any]] {
            items = itemsData.compactMap { itemData in
                let itemId = itemData["id"] as? String ?? UUID().uuidString
                let name = itemData["name"] as? String
                let price = itemData["price"] as? Double
                let quantity = itemData["quantity"] as? Double
                let itemCategory = itemData["category"] as? String
                
                return ReceiptItem(id: itemId, name: name, price: price, quantity: quantity, category: itemCategory)
            }
        }
        
        return Receipt(
            id: documentId,
            storeName: storeName,
            date: date,
            totalAmount: totalAmount,
            taxAmount: taxAmount,
            tipAmount: tipAmount,
            items: items,
            scannedTime: scannedTime,
            userId: userId,
            category: category,
            transactionDateTime: transactionDateTime
        )
    }

    func addReceipt(_ receipt: Receipt, forUser userId: String, completion: @escaping (Error?) -> Void) {
        do {
            let documentId = receipt.id // Use the receipt's id directly since it's now non-optional
            let finalReceipt = receipt
            
            print("FirestoreManager: Attempting to save receipt with ID '\(documentId)' for user '\(userId)'.")
            print("FirestoreManager: Receipt data: \(finalReceipt)")

            let ref = db.collection("users").document(userId).collection("receipts").document(documentId)
            try ref.setData(from: finalReceipt, merge: true) { error in
                if error == nil {
                    print("FirestoreManager: setData reported success. Refreshing cache.")
                    self.refreshCache(forUser: userId)
                }
                completion(error)
            }
        } catch {
            completion(error)
        }
    }

    func deleteReceipt(_ receiptId: String, forUser userId: String, completion: @escaping (Error?) -> Void) {
        let ref = db.collection("users").document(userId).collection("receipts").document(receiptId)
        ref.delete { error in
            if error == nil {
                self.refreshCache(forUser: userId)
            }
            completion(error)
        }
    }

    func refreshCache(forUser userId: String) {
        fetchReceipts(forUser: userId) { result in
            switch result {
            case .success(let receipts):
                DispatchQueue.main.async {
                    self.receiptsCache = receipts
                }
            case .failure(let error):
                print("Error refreshing cache: \(error.localizedDescription)")
            }
        }
    }
    
    func cacheReceipt(_ receipt: Receipt) {
        DispatchQueue.main.async {
            if !self.receiptsCache.contains(where: { $0.id == receipt.id }) {
                self.receiptsCache.append(receipt)
            }
        }
    }
}
