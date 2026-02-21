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

    /// Инициализация из словаря (например, из Firestore document.data() при использовании DatabaseService).
    init?(fromDocumentData data: [String: Any], nutritionData: [String: Any]?) {
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
        let fromDoc = Nutrition(from: data)
        let fromSub = Nutrition(from: nutritionData)
        self.nutrition = Nutrition(
            weight: fromSub.weight ?? fromDoc.weight,
            callories: fromSub.callories ?? fromDoc.callories,
            protein: fromSub.protein ?? fromDoc.protein,
            fats: fromSub.fats ?? fromDoc.fats
        )
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
