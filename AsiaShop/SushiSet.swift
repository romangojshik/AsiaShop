//
//  Set.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import Foundation
import FirebaseFirestore

struct SushiSet {
    var id: String
    var title: String
    var imageURL: String
    var price: Double
    var description: String
    var weight: String
    var callories: String?
    var composition: String?
    
    init(
        id: String,
        title: String,
        imageURL: String,
        price: Double,
        description: String,
        weight: String,
        callories: String? = nil,
        composition: String? = nil
    ) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.price = price
        self.description = description
        self.weight = weight
        self.callories = callories
        self.composition = composition
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard
            let id = data["id"] as? String,
            let title = data["title"] as? String,
            let imageURL = data["imageURL"] as? String,
            let price = data["price"] as? Double,
            let description = data["description"] as? String,
            let weight = data["weight"] as? String
                
        else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.price = price
        self.description = description
        self.weight = weight
        self.callories = data["callories"] as? String
        self.composition = data["composition"] as? String
    }
}

extension SushiSet {
    func toProduct() -> Product {
        return Product(
            id: "set_\(self.id)", // Добавляем префикс "set_" чтобы отличать от обычных продуктов
            title: self.title,
            imageURL: self.imageURL,
            price: self.price,
            description: self.description,
            weight: self.weight,
            callories: self.callories,
            composition: self.composition
        )
    }
}
