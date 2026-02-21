//
//  DatabaseService.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 3.12.23.
//

import FirebaseFirestore

protocol DatabaseServiceProtocol {
    func getSushi(completion: @escaping (Result<[Sushi], Error>) -> ())
    func getSets(completion: @escaping (Result<[SushiSet], Error>) -> ())
}

class DatabaseService: DatabaseServiceProtocol {
    static let shared = DatabaseService()
    
    private let dataBase = Firestore.firestore()
    
    private var usersReferance: CollectionReference {
        return dataBase.collection("users")
    }
    private var ordersReferance: CollectionReference {
        return dataBase.collection("orders")
    }
    private var sushiReference: CollectionReference {
        return dataBase.collection("sushi")
    }
    private var setsReference: CollectionReference {
        return dataBase.collection("sets")
    }
    private var ordersReference: CollectionReference {
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
    
    func setOrder(
        order: Order,
        completion: @escaping (Result<Order, Error>) -> Void
    ) {
        var orderData: [String: Any] = [
            "id": order.id,
            "userName": order.userName,
            "numberPhone": order.numberPhone,
            "status": order.status.rawValue,
            "total": order.total,
            "createdAt": Timestamp(date: order.createdAt),
            "positions": order.positions.map { position in
                return [
                    "id": position.id,
                    "count": position.count,
                    "cost": position.cost,
                    "product": [
                        "id": position.product.id,
                        "title": position.product.title,
                        "imageURL": position.product.imageURL,
                        "price": position.product.price,
                        "description": position.product.description,
                        "weight": position.product.nutrition?.weight ?? "",
                        "callories": position.product.nutrition?.callories ?? "",
                        "protein": position.product.nutrition?.protein ?? "",
                        "fats": position.product.nutrition?.fats ?? ""
                    ]
                ]
            }
        ]
        
        if let readyBy = order.readyBy {
            orderData["readyBy"] = Timestamp(date: readyBy)
        }
        
        ordersReference.addDocument(data: orderData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
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

    // Загрузка списка суши из коллекции "sushi" и подколлекции "nutrition"
    func getSushi(completion: @escaping (Result<[Sushi], Error>) -> ()) {
        sushiReference.getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let querySnapshot = querySnapshot else {
                completion(.success([]))
                return
            }

            let group = DispatchGroup()
            var sushiByIndex: [Sushi?] = Array(repeating: nil, count: querySnapshot.documents.count)
            var loadError: Error?

            for (index, document) in querySnapshot.documents.enumerated() {
                group.enter()

                let nutritionRef = self.sushiReference
                    .document(document.documentID)
                    .collection("nutrition")

                nutritionRef.getDocuments { nutritionSnapshot, nutritionError in
                    defer { group.leave() }

                    if let nutritionError = nutritionError, loadError == nil {
                        loadError = nutritionError
                        return
                    }

                    let nutritionData = nutritionSnapshot?.documents.first?.data()
                    if let sushiItem = Sushi(document: document, nutritionData: nutritionData) {
                        sushiByIndex[index] = sushiItem
                    }
                }
            }

            group.notify(queue: .main) {
                if let loadError = loadError {
                    completion(.failure(loadError))
                } else {
                    completion(.success(sushiByIndex.compactMap { $0 }))
                }
            }
        }
    }
    
    // Загрузка списка сетов из коллекции "sets" и подколлекции "nutrition"
    func getSets(completion: @escaping (Result<[SushiSet], Error>) -> ()) {
        setsReference.getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let querySnapshot = querySnapshot else {
                completion(.success([]))
                return
            }

            let group = DispatchGroup()
            var setsByIndex: [SushiSet?] = Array(repeating: nil, count: querySnapshot.documents.count)
            var loadError: Error?

            for (index, document) in querySnapshot.documents.enumerated() {
                group.enter()

                let nutritionRef = self.setsReference
                    .document(document.documentID)
                    .collection("nutrition")

                nutritionRef.getDocuments { nutritionSnapshot, nutritionError in
                    defer { group.leave() }

                    if let nutritionError = nutritionError, loadError == nil {
                        loadError = nutritionError
                        return
                    }

                    let nutritionData = nutritionSnapshot?.documents.first?.data()
                    if let sushiSet = SushiSet(fromDocumentData: document.data(), nutritionData: nutritionData) {
                        setsByIndex[index] = sushiSet
                    }
                }
            }

            group.notify(queue: .main) {
                if let loadError = loadError {
                    completion(.failure(loadError))
                } else {
                    completion(.success(setsByIndex.compactMap { $0 }))
                }
            }
        }
    }
}
