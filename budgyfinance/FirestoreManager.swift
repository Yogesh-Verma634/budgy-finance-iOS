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

    // Fetch receipts
    func fetchReceipts(forUser userId: String, completion: @escaping (Result<[Receipt], Error>) -> Void) {
        db.collection("users").document(userId).collection("receipts").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let documents = snapshot?.documents {
                do {
                    let receipts: [Receipt] = try documents.map { document in
                        let receipt = try document.data(as: Receipt.self)
                        return receipt
                    }
                    completion(.success(receipts))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
