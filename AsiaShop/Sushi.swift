//
//  Sushi.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 29.01.26.
//

import Foundation

struct Sushi: Identifiable, Decodable {
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

// Расширение для конвертации Sushi в Product
extension Sushi {
    func toProduct() -> Product {
        return Product(
            id: self.id,
            imageURL: self.imageURL,
            title: self.title,
            description: self.description,
            price: self.price,
            composition: self.composition,
            nutrition: self.nutrition
        )
    }
}
