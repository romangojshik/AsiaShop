//
//  ProductDetailViewModel.swift
//  AsiaShop
//
//  Created by Roman on 11/23/23.
//

import Foundation

class ProductDetailViewModel: ObservableObject {
    
    @Published var product: Product
    @Published var count = 0
    
    init(product: Product) {
        self.product = product
    }
}
