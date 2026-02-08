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
    var imageURL: String
    var title: String
    var description: String
    var price: Double
    var composition: String?

    var weight: String?
    var callories: String?
    var protein: String?
    var fats: String?

    init(
        id: String,
        imageURL: String,
        title: String,
        description: String,
        price: Double,
        composition: String? = nil,
        weight: String? = nil,
        callories: String? = nil,
        protein: String? = nil,
        fats: String? = nil
    ) {
        self.id = id
        self.imageURL = imageURL
        self.title = title
        self.description = description
        self.price = price
        self.composition = composition
        self.weight = weight
        self.callories = callories
        self.protein = protein
        self.fats = fats
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard
            let id = data["id"] as? String,
            let imageURL = data["imageURL"] as? String,
            let title = data["title"] as? String,
            let description = data["description"] as? String,
            let price = data["price"] as? Double
        else {
            return nil
        }

        self.id = id
        self.imageURL = imageURL
        self.title = title
        self.description = description
        self.price = price
        self.composition = data["composition"] as? String
        self.weight = data["weight"] as? String
        self.callories = data["callories"] as? String
        self.protein = data["protein"] as? String
        self.fats = data["fats"] as? String
    }
}

extension SushiSet {
    func toProduct() -> Product {
        return Product(
            id: "set_\(self.id)",
            imageURL: self.imageURL,
            title: self.title,
            description: self.description,
            price: self.price,
            composition: self.composition,
            weight: self.weight,
            callories: self.callories,
            protein: self.protein,
            fats: self.fats
        )
    }
}
