//
//  Product.swift
//  AsiaShop
//
//  Created by Roman on 11/21/23.
//

import Foundation

struct Product: Identifiable {
    var id: String
    var title: String
    var imageURL: String
    var price: Double
    var description: String
    var weight: String?
    var callories: String?
    var composition: String?
//    var ordersCount: Int
//    var isRecommend: Bool
}
