//
//  Set.swift
//  AsiaShop
//
//  Created by AI on request.
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
    
    var representation: [String: Any] {
        [
            "id": id,
            "title": title,
            "imageURL": imageURL,
            "price": price,
            "description": description,
            "weight": weight
        ]
    }
    
    init(
        id: String,
        title: String,
        imageURL: String,
        price: Double,
        description: String,
        weight: String
    ) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.price = price
        self.description = description
        self.weight = weight
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
    }
}

// Расширение для конвертации SushiSet в Product
extension SushiSet {
    func toProduct() -> Product {
        return Product(
            id: self.id,
            title: self.title,
            imageURL: self.imageURL,
            price: self.price,
            description: self.description,
            weight: self.weight
        )
    }
}
