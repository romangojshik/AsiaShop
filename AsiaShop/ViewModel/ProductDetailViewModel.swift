//
//  ProductDetailViewModel.swift
//  AsiaShop
//
//  Created by Roman on 11/23/23.
//

import Foundation

class ProductDetailViewModel: ObservableObject {
    
    @Published var product: Product
    @Published var sizes = ["4 штуки", "6 штук", "8 штук"]
    @Published var count = 0
    
    init(product: Product) {
        self.product = product
    }
    
    func getPrice(size: String) -> Double {
        switch size {
        case "4 штуки": return product.price
        case "6 штук": return product.price * 1.25
        case  "8 штук": return product.price * 1.5
        default: return 0.0
        }
    }
}
