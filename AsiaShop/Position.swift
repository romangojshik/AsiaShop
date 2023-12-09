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
    
    var representation: [String: Any] {
        var repres = [String: Any]()
        
        repres["id"] = id
        repres["count"] = count
        repres["title"] = product.title
        repres["price"] = product.price
        repres["cost"] = self.cost

        return repres
    }
}
