//
//  Product.swift
//  AsiaShop
//
//  Created by Roman on 11/21/23.
//

import Foundation

struct Product: Identifiable {
    var id: String
    var imageURL: String
    var title: String
    var description: String
    var price: Double
    var composition: String? = nil

    var weight: String? = nil
    var callories: String? = nil
    var protein: String? = nil
    var fats: String? = nil

    var hasNutritionAttributes: Bool {
        [weight, callories, protein, fats].contains { ($0 ?? "").isEmpty == false }
    }
}
