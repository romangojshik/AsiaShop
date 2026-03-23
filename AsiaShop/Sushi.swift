//
//  Sushi.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 29.01.26.
//

import Foundation

/// API ответ каталога роллов.
/// Поддерживает оба варианта ключа ответа: `rolls` (новый) и `sushi` (старый/совместимость).
struct RollsAPIResponse: Decodable {
    let rolls: [Roll]

    private enum CodingKeys: String, CodingKey {
        case rolls
        case sushi
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let decodedRolls = try container.decodeIfPresent([Roll].self, forKey: .rolls) {
            self.rolls = decodedRolls
        } else {
            self.rolls = try container.decode([Roll].self, forKey: .sushi)
        }
    }
}

/// Единица каталога роллов.
struct Roll: Identifiable, Decodable {
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

// Расширение для конвертации Roll в Product
extension Roll {
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
