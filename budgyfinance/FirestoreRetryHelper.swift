//
//  FirestoreRetryHelper.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 27/12/24.
//

import FirebaseFirestore
import Foundation

class FirestoreRetryHelper {
    static func performFirestoreOperationWithRetry<T>(
        operation: @escaping (@escaping (Result<T, Error>) -> Void) -> Void,
        maxRetries: Int = 3,
        delay: TimeInterval = 1.0,
        onCompletion: @escaping (Result<T, Error>) -> Void
    ) {
        var currentRetry = 0

        func attemptOperation() {
            operation { result in
                switch result {
                case .success(let data):
                    onCompletion(.success(data))
                case .failure(let error):
                    if currentRetry < maxRetries {
                        currentRetry += 1
                        let backoffDelay = delay * pow(2.0, Double(currentRetry))
                        print("Retrying in \(backoffDelay) seconds... (Attempt \(currentRetry))")
                        DispatchQueue.global().asyncAfter(deadline: .now() + backoffDelay) {
                            attemptOperation()
                        }
                    } else {
                        print("Max retries reached. Failing with error: \(error.localizedDescription)")
                        onCompletion(.failure(error))
                    }
                }
            }
        }

        attemptOperation()
    }
}
