import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    // Save a receipt
    func saveReceipt(_ receipt: Receipt, forUser userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let receiptData = try Firestore.Encoder().encode(receipt)
            db.collection("users").document(userId).collection("receipts").addDocument(data: receiptData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    // Centralized fetch function for receipts
    func fetchReceipts(completion: @escaping (Result<[Receipt], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("receipts")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                var decodedReceipts: [Receipt] = []

                for document in documents {
                    let data = document.data()
                    print("Raw Document Data: \(data)") // Debugging

                    // Manually map the document to the `Receipt` model
                    let receipt = Receipt(
                        id: document.documentID, // Extract the Firestore document ID
                        storeName: data["storeName"] as? String,
                        date: (data["date"] as? Timestamp)?.dateValue().description ?? data["date"] as? String,
                        totalAmount: data["totalAmount"] as? Double,
                        taxAmount: data["taxAmount"] as? Double,
                        tipAmount: data["tipAmount"] as? Double,
                        items: (data["items"] as? [[String: Any]])?.compactMap { itemData in
                            ReceiptItem(
                                name: itemData["name"] as? String,
                                price: itemData["price"] as? Double,
                                quantity: itemData["quantity"] as? Double
                            )
                        }
                    )

                    decodedReceipts.append(receipt)
                }

                completion(.success(decodedReceipts))
            }
    }
}
