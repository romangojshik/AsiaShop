//
//  ProductDetailView.swift
//  AsiaShop
//
//  Created by Roman on 11/21/23.
//

import SwiftUI

struct ProductDetailView: View {
    
    var product: Product
    
    var body: some View {
        Text("\(product.title)")
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: Product(
            id: "3",
            title: "Нори",
            imageURL: "String",
            price: 17.5,
            description: "Наши жареные роллы — это искусство, созданное любовью"
        ))
    }
}
