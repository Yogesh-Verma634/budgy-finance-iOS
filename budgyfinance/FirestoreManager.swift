import FirebaseFirestore
import FirebaseAuth

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    // Save a receipt
    func saveReceipt(_ receipt: Receipt, forUser userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            var receiptData = try Firestore.Encoder().encode(receipt)
            if let scannedTime = receipt.scannedTime {
                receiptData["scannedTime"] = Timestamp(date: scannedTime) // Convert Date to Timestamp
                print("Saving scannedTime: \(scannedTime)") // Debugging
            }
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
        db.collection("users").document(Auth.auth().currentUser?.uid ?? "").collection("receipts")
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
                            print("Item Data: \(itemData)") // Debugging
                            return ReceiptItem(
                                name: itemData["name"] as? String,
                                price: itemData["price"] as? Double,
                                quantity: itemData["quantity"] as? Double
                            )
                        },
                        scannedTime: (data["scannedTime"] as? Timestamp)?.dateValue() // Convert Timestamp to Date
                    )

                    print("Fetched scannedTime: \(receipt.scannedTime ?? Date())") // Debugging
                    decodedReceipts.append(receipt)
                }

                print("Decoded Receipts: \(decodedReceipts)") // Debugging
                completion(.success(decodedReceipts))
            }
    }

    func deleteReceipt(withId id: String, forUser userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("users").document(userId).collection("receipts").document(id).delete { error in
            if let error = error {
                print("Error deleting receipt: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Receipt successfully deleted")
                completion(.success(()))
            }
        }
    }
}
