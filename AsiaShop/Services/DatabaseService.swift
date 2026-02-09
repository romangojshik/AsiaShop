//
//  DatabaseService.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 3.12.23.
//

import FirebaseFirestore

protocol DatabaseServiceProtocol {
    func getProducts(completion: @escaping (Result<[Product], Error>) -> ())
    func getSushi(completion: @escaping (Result<[Sushi], Error>) -> ())
    func getSets(completion: @escaping (Result<[SushiSet], Error>) -> ())
    func getSushiAndSets(completion: @escaping (Result<(sushi: [Sushi], sets: [SushiSet]), Error>) -> ())
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
    private var productsReference: CollectionReference {
        return dataBase.collection("products")
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

    // Загрузка списка продуктов из коллекции "products"
    func getProducts(completion: @escaping (Result<[Product], Error>) -> ()) {
        productsReference.getDocuments { querySnapshot, error in
            if let querySnapshot = querySnapshot {
                var products: [Product] = []
                for document in querySnapshot.documents {
                    let data = document.data()
                    
                    guard
                        let id = data["id"] as? String,
                        let title = data["title"] as? String,
                        let imageURL = data["imageURL"] as? String,
                        let price = data["price"] as? Double,
                        let description = data["description"] as? String
                    else {
                        continue
                    }
                    
                    let product = Product(
                        id: id,
                        imageURL: imageURL,
                        title: title,
                        description: description,
                        price: price,
                        composition: nil,
                        nutrition: nil
                    )
                    products.append(product)
                }
                completion(.success(products))
            } else if let error = error {
                completion(.failure(error))
            }
        }
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
                    if let sushiSet = SushiSet(document: document, nutritionData: nutritionData) {
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
    
    // Параллельная загрузка суши и сетов с использованием DispatchGroup
    func getSushiAndSets(completion: @escaping (Result<(sushi: [Sushi], sets: [SushiSet]), Error>) -> ()) {
        let group = DispatchGroup()
        var loadedSushi: [Sushi] = []
        var loadedSets: [SushiSet] = []
        var loadError: Error?
        
        // Загружаем суши
        group.enter()
        getSushi { result in
            switch result {
            case .success(let sushi):
                loadedSushi = sushi
            case .failure(let error):
                loadError = error
            }
            group.leave()
        }
        
        // Загружаем сеты
        group.enter()
        getSets { result in
            switch result {
            case .success(let sets):
                loadedSets = sets
            case .failure(let error):
                loadError = error
            }
            group.leave()
        }
        
        // Ждём завершения обоих запросов
        group.notify(queue: .main) {
            if let error = loadError {
                completion(.failure(error))
            } else {
                completion(.success((sushi: loadedSushi, sets: loadedSets)))
            }
        }
    }
}
