//
//  FirebaseTest.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 27/12/24.
//

import FirebaseFirestore

func testFirestoreConnection() {
    let db = Firestore.firestore()
    db.collection("test").addDocument(data: ["key": "value"]) { error in
        if let error = error {
            print("Error writing to Firestore: \(error.localizedDescription)")
        } else {
            print("Firestore write succeeded!")
        }
    }
}
