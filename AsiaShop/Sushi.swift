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

    init?(document: QueryDocumentSnapshot) {
        self.init(document: document, nutritionData: nil)
    }

    /// Инициализация из документа суши и опциональных данных из подколлекции `nutrition`.
    init?(document: QueryDocumentSnapshot, nutritionData: [String: Any]?) {
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

        // Питательность: приоритет у подколлекции `nutrition`, затем у полей документа
        let fromDocument = Nutrition(from: data)
        let fromSubcollection = Nutrition(from: nutritionData)
        self.nutrition = Nutrition(
            weight: fromSubcollection.weight ?? fromDocument.weight,
            callories: fromSubcollection.callories ?? fromDocument.callories,
            protein: fromSubcollection.protein ?? fromDocument.protein,
            fats: fromSubcollection.fats ?? fromDocument.fats
        )
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
