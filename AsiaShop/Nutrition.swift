//
//  Nutrition.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 8.02.26.
//

import Foundation

struct Nutrition {
    var weight: String?
    var callories: String?
    var protein: String?
    var fats: String?

    init(
        weight: String? = nil,
        callories: String? = nil,
        protein: String? = nil,
        fats: String? = nil
    ) {
        self.weight = weight
        self.callories = callories
        self.protein = protein
        self.fats = fats
    }

    /// Инициализация из данных Firestore (документ или подколлекция `nutrition`).
    init(from data: [String: Any]?) {
        self.weight = data?["weight"] as? String
        self.callories = data?["callories"] as? String
        self.protein = data?["protein"] as? String
        self.fats = data?["fats"] as? String
    }
}
