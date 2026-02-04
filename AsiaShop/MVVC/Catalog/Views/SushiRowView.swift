//
//  SushiRowView.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import SwiftUI

struct SushiRowView: View {
    @ObservedObject var basketViewModel: BasketViewModel
    let sushi: Sushi
    let onAddToBasket: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(sushi.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(sushi.title)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(sushi.description)
                    .font(.subheadline)
                    .foregroundColor(Color.black.opacity(0.7))
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(String(format: "%.0fруб/8шт", sushi.price))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Constants.Colors.blackOpacity90)
                    
                    Spacer()
                    
                    QuantityButton(
                        count: basketViewModel.getProductCount(productId: sushi.id),
                        onDecrease: {
                            if let position = basketViewModel.positions.first(where: { $0.product.id == sushi.id }) {
                                basketViewModel.decreaseCount(positionId: position.id)
                            }
                        },
                        onIncrease: {
                            if let position = basketViewModel.positions.first(where: { $0.product.id == sushi.id }) {
                                basketViewModel.increaseCount(positionId: position.id)
                            } else {
                                onAddToBasket()
                            }
                        },
                        isInBasket: basketViewModel.isProductInBasket(productId: sushi.id),
                        onAddToBasket: onAddToBasket
                    )
                }
            }
            
        }
        .padding(.horizontal)
    }
}

// MARK: - Constants

private struct Constants {
    struct Colors {
        static let blackOpacity70 = Color.black.opacity(0.7)
        static let blackOpacity90 = Color.black.opacity(0.9)

    }
}
