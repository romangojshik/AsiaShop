//
//  Position.swift
//  AsiaShop
//
//  Created by Roman on 11/23/23.
//

import Foundation

struct Position {
    var id: String
    var product: Product
    var count: Int
    
    var cost: Double {
        return product.price * Double(count)
    }
}
