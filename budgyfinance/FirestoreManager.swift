//
//  FirestoreManager.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 26/12/24.
//

import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    // Save a receipt
    func saveReceipt(_ receipt: Receipt, forUser userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let receiptData = receipt.toDictionary()
        db.collection("users").document(userId).collection("receipts").addDocument(data: receiptData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // Fetch receipts
    func fetchReceipts(forUser userId: String, completion: @escaping (Result<[Receipt], Error>) -> Void) {
        db.collection("users").document(userId).collection("receipts").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let documents = snapshot?.documents {
                let receipts: [Receipt] = documents.compactMap { document in
                    let data = document.data()
                    return Receipt.fromDictionary(data)
                }
                completion(.success(receipts))
            }
        }
    }
}
