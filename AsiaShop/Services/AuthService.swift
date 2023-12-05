//
//  AuthService.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 30.11.23.
//

import Foundation
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    private let auth = Auth.auth()
    
    var currentUser: User? {
        return auth.currentUser
    }
    
    func singUp(
        email: String,
        password: String,
        completion: @escaping(Result<User, Error>) -> ()
    ) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let result = result {
                let profile = Profile(
                    id: result.user.uid,
                    name: "",
                    phone: 0,
                    address: ""
                )
                DatabaseService.shared.setProfile(user: profile) { resultDB in
                    switch resultDB {
                    case .success(_):
                        completion(.success(result.user))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func signIn(
        email: String,
        password: String,
        completion: @escaping(Result<User, Error>) -> ()
    ) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let result = result {
                completion(.success(result.user))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}
