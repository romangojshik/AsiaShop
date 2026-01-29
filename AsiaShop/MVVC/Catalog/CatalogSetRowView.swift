//
//  CatalogSetRowView.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import SwiftUI

struct CatalogSetRowView: View {
    @ObservedObject var basket: BasketViewModel
    let sushiSet: SushiSet
    
    private var product: Product {
        sushiSet.toProduct()
    }
    
    private var isInBasket: Bool {
        basket.isProductInBasket(productId: product.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                Image(sushiSet.imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: screen.width * 0.3, height: screen.width * 0.3)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                Button {
                    let position = Position(
                        id: UUID().uuidString,
                        product: product,
                        count: 1
                    )
                    basket.addPosition(position)
                } label: {
                    Image(systemName: isInBasket ? "checkmark" : "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isInBasket ? .white : .black)
                        .frame(width: 30, height: 30)
                        .background(isInBasket ? Color.green : Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
                }
                .padding(6)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(2)
                
                Text(product.weight ?? "")
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                
                HStack {
                    Text(String(format: "%.0fруб/сет", product.price))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 4)
        }
    }
}

