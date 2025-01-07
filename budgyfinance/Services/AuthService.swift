//
//  AuthService.swift
//  budgyfinance
//
//  Created by Yogesh Verma on 29/12/24.
//


import FirebaseAuth
import Combine

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    func login(email: String, password: String) -> AnyPublisher<User, Error> {
        Future { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("Firebase Login Error: \(error.localizedDescription)")
                    promise(.failure(error))
                } else if let user = result?.user {
                    print("Login successful for user: \(result?.user.uid ?? "unknown")")
                    promise(.success(user))
                } else {
                    print("Unexpected error: No user returned")
                    promise(.failure(NSError(domain: "AuthService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown login error"])))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func register(email: String, password: String) -> AnyPublisher<User, Error> {
        Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let user = result?.user {
                    promise(.success(user))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, Error> {
        Future { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
