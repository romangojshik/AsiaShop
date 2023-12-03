//
//  DatabaseService.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 3.12.23.
//

import FirebaseFirestore

class DatabaseService {
    static let shared = DatabaseService()
    private let dataBase = Firestore.firestore()
    private var usersReferance: CollectionReference {
        return dataBase.collection("users")
    }
    
    private init() { }
    
    func setUser(user: Profile, completion: @escaping (Result<Profile, Error>) -> ()) {
        usersReferance.document(user.id).setData(user.representation) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(user))
            }
        }
    }
}
