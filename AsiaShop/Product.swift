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

    var nutrition: Nutrition?
}
