//
//  Position.swift
//  AsiaShop
//
//  Created by Roman on 11/23/23.
//

import Foundation

struct Position: Identifiable {
    var id: String
    var product: Product
    var count: Int
    
    var cost: Double {
        return product.price * Double(count)
    }
    
    init(
        id: String,
        product: Product,
        count: Int
    ) {
        self.id = id
        self.product = product
        self.count = count
    }
}
