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
    
    private var currentUser: User? {
        return auth.currentUser
    }
    
    func singUp(
        email: String,
        password: String,
        complition: @escaping(Result<User, Error>) -> ()
    ) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let result = result {
                complition(.success(result.user))
            } else if let error = error {
                complition(.failure(error))
            }
        }
    }
}
