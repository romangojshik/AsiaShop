//
//  CatalogProductSmallCell.swift
//  AsiaShop
//
//  Created by AI on request.
//

import SwiftUI

struct CatalogProductSmallCell: View {
    let product: Product
    
    var body: some View {
        let side = screen.width * 0.24
        
        return VStack(spacing: 4) {
            Image(product.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: side, height: side) // квадрат
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            HStack {
                Text(product.title)
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)
                Spacer()
                Text(String(format: "%.0f ₽", product.price))
                    .font(.system(size: 11, weight: .semibold))
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 4)
        }
        .frame(width: side + 22)
        .padding(6)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

struct CatalogProductSmallCell_Previews: PreviewProvider {
    static var previews: some View {
        CatalogProductSmallCell(
            product: Product(
                id: "1",
                imageURL: "taru",
                title: "Тару",
                description: "Ролл Тару — идеальное сочетание сливочного сыра, нежного лосося и тунца",
                price: 16.5,
                composition: nil,
                nutrition: nil
            )
        )
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}

