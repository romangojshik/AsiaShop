//
//  Sushi.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 29.01.26.
//

import Foundation
import FirebaseFirestore

struct Sushi: Identifiable {
    var id: String
    var title: String
    var imageURL: String
    var price: Double
    var description: String
    var weight: String?
    var callories: String?
    var composition: String?
    
    init(
        id: String,
        title: String,
        imageURL: String,
        price: Double,
        description: String,
        weight: String? = nil,
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
            let description = data["description"] as? String

        else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.price = price
        self.description = description
        self.weight = data["weight"] as? String
        self.callories = data["callories"] as? String
        self.composition = data["composition"] as? String
    }
}

// Расширение для конвертации Sushi в Product
extension Sushi {
    func toProduct() -> Product {
        return Product(
            id: self.id,
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
