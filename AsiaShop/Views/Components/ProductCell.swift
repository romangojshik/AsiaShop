//
//  ProductCell.swift
//  AsiaShop
//
//  Created by Roman on 11/21/23.
//

import SwiftUI

struct ProductCell: View {
    var product: Product
    
    var body: some View {
        VStack(spacing: 2) {
            Image("Taru")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: screen.width * 0.45)
                .clipped()
                .cornerRadius(16)
            HStack {
                Text(product.title)
                    .font(.custom("AvenirNext-regular", size: 12))
                Spacer()
                Text(String(format: "%.2f", product.price) + " руб")
                    .font(.custom("AvenirNext-bold", size: 12))
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 6)
        }.frame(
            width: screen.width * 0.45,
            height: screen.width * 0.5
        )
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

struct ProductCell_Previews: PreviewProvider {
    static var previews: some View {
        ProductCell(product: Product(
            id: "1",
            title: "Тару",
            imageURL: "String",
            price: 15.5,
            description: "Ролл Тару — идеальное сочетание сливочного сыра, нежного лосося и тунца"
        ))
    }
}
