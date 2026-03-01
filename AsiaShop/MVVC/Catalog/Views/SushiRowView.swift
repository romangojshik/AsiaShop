//
//  SushiRowView.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import SwiftUI

struct SushiRowView: View {
    @EnvironmentObject var storage: OrderDataStorage
    
    let sushi: Sushi
    let onAddToBasket: () -> Void
    
    var body: some View {
        HStack(spacing: AppConstants.Padding.padding16) {
            URLImageView(urlString: sushi.imageURL)
                .frame(width: Constants.Size.sushiWidth, height: Constants.Size.sushiWidth)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.Padding.padding16))
            
            VStack(alignment: .leading, spacing: AppConstants.Padding.padding8) {
                Text(sushi.title)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(sushi.composition ?? .empty)
                    .font(.subheadline)
                    .foregroundColor(AppConstants.Colors.blackOpacity70)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(String.costForSyshi(sushi.price))
                        .font(.system(size: AppConstants.Padding.padding16, weight: .bold))
                        .foregroundColor(AppConstants.Colors.blackOpacity90)
                    
                    Spacer()
                    
                    QuantityButton(
                        count: storage.getProductCount(productId: sushi.id),
                        onDecrease: {
                            if let position = storage.positions.first(where: { $0.product.id == sushi.id }) {
                                storage.decreaseOrRemove(positionId: position.id)
                            }
                        },
                        onIncrease: {
                            if let position = storage.positions.first(where: { $0.product.id == sushi.id }) {
                                storage.increaseCount(positionId: position.id)
                            } else {
                                onAddToBasket()
                            }
                        },
                        isInBasket: storage.isProductInBasket(productId: sushi.id),
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
    struct Size {
        static let sushiWidth: CGFloat = 96.0
    }
}
