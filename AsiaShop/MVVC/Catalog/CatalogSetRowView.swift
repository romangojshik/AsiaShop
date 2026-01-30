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
    
    private let cardWidth: CGFloat = 120
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                Image(sushiSet.imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardWidth, height: cardWidth)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                QuantityPlusButton(
                    count: basket.getProductCount(productId: product.id),
                    containerWidth: cardWidth - 12, // Ширина минус padding (6px с каждой стороны)
                    onDecrease: {
                        if let position = basket.positions.first(where: { $0.product.id == product.id }) {
                            basket.decreaseCount(positionId: position.id)
                        }
                    },
                    onIncrease: {
                        if let position = basket.positions.first(where: { $0.product.id == product.id }) {
                            basket.increaseCount(positionId: position.id)
                        } else {
                            let position = Position(
                                id: UUID().uuidString,
                                product: product,
                                count: 1
                            )
                            basket.addPosition(position)
                        }
                    },
                    onAddToBasket: {
                        let position = Position(
                            id: UUID().uuidString,
                            product: product,
                            count: 1
                        )
                        basket.addPosition(position)
                    }
                )
                .padding(.horizontal, 6)
                .padding(.bottom, 6)
            }
            .clipped()
            
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

