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
    private var ordersReferance: CollectionReference {
        return dataBase.collection("orders")
    }
    
    private init() { }
    
    func setProfile(user: Profile, completion: @escaping (Result<Profile, Error>) -> ()) {
        usersReferance.document(user.id).setData(user.representation) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(user))
            }
        }
    }
    
    func getProfile(completion: @escaping (Result<Profile, Error>) -> ()) {
        guard let currentUser = AuthService.shared.currentUser else { return }
        
        usersReferance.document(currentUser.uid).getDocument { docSnapshot, error in
            guard let snapshot = docSnapshot else { return }
            guard let data = snapshot.data() else { return }
            
            guard let usedID = data["id"] as? String else { return }
            guard let userName = data["name"] as? String else { return }
            guard let userPhone = data["phone"] as? Int else { return }
            guard let userAddress = data["address"] as? String else { return }
            
            let profile = Profile(id: usedID, name: userName, phone: userPhone, address: userAddress)
            completion(.success(profile))
        }
    }
    
    func setOrder(order: Order, completion: @escaping (Result<Order, Error>) -> ()) {
        ordersReferance.document(order.id).setData(order.representation) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.setPositions(
                    orderID: order.id,
                    positions: order.positions
                ) { result in
                    switch result {
                    case .success(let positions):
                        print(positions.count)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                completion(.success(order))
            }
        }
    }
    
    func setPositions(
        orderID: String,
        positions: [Position],
        completion: @escaping (Result<[Position], Error>) -> ()
    ) {
        let positionsReferance = ordersReferance.document(orderID).collection("positions")
        
        for position in positions {
            positionsReferance.document(position.id).setData(position.representation)
        }
        
        completion(.success(positions))
    }
    
    func getOrders(userID: String?,  completion: @escaping (Result<[Order], Error>) -> ()) {
        self.ordersReferance.getDocuments { querySnapshot, error in
            if let querySnapshot = querySnapshot {
                var orders = [Order]()
                for document in querySnapshot.documents {
                    if let userID = userID {
                        if let order = Order(document: document), order.userID == userID {
                            orders.append(order)
                        }
                    } else {
                        if let order = Order(document: document) {
                            orders.append(order)
                        }
                    }
                }
                completion(.success(orders))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func getPositions(orderID: String?,  completion: @escaping (Result<[Position], Error>) -> ()) {
        guard let orderID = orderID else { return }
        let positionsReferance = ordersReferance.document(orderID).collection("positions")
        positionsReferance.getDocuments { querySnapshot, error in
            if let querySnapshot = querySnapshot {
                var positions = [Position]()
                for document in querySnapshot.documents {
                    if let position = Position(document: document) {
                        positions.append(position)
                    }
                }
                completion(.success(positions))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}
