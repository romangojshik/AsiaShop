//
//  Set.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import Foundation

struct SushiSet: Decodable {
    var id: String
    var imageURL: String
    var title: String
    var description: String
    var price: Double
    var composition: String?
    var nutrition: Nutrition?

    init(
        id: String,
        imageURL: String,
        title: String,
        description: String,
        price: Double,
        composition: String? = nil,
        nutrition: Nutrition? = nil
    ) {
        self.id = id
        self.imageURL = imageURL
        self.title = title
        self.description = description
        self.price = price
        self.composition = composition
        self.nutrition = nutrition
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
            nutrition: self.nutrition
        )
    }
}
