//
//  SushiRowView.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import SwiftUI

struct RollRowView: View {
    @EnvironmentObject var storage: OrderDataStorage
    
    let roll: Roll
    let onAddToBasket: () -> Void
    
    var body: some View {
        HStack(spacing: AppConstants.Padding.padding16) {
            URLImageView(urlString: roll.imageURL)
                .frame(width: Constants.Size.sushiWidth, height: Constants.Size.sushiWidth)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.Padding.padding16))
            
            VStack(alignment: .leading, spacing: AppConstants.Padding.padding4) {
                Text(roll.title)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(roll.composition ?? .empty)
                    .font(.subheadline)
                    .foregroundColor(AppConstants.Colors.blackOpacity70)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                
                Text(String.defaultCountSushi(roll.nutrition?.weight ?? .empty))
                    .font(.descriptionFont)
                    .foregroundColor(.gray)
                
                HStack {
                    Text(String.costForSyshi(roll.price))
                        .font(.system(size: AppConstants.Padding.padding16, weight: .bold))
                        .foregroundColor(AppConstants.Colors.blackOpacity90)
                    
                    Spacer()
                    
                    QuantityButton(
                        count: storage.getProductCount(productId: roll.id),
                        onDecrease: {
                            if let position = storage.positions.first(where: { $0.product.id == roll.id }) {
                                storage.decreaseOrRemove(positionId: position.id)
                            }
                        },
                        onIncrease: {
                            if let position = storage.positions.first(where: { $0.product.id == roll.id }) {
                                storage.increaseCount(positionId: position.id)
                            } else {
                                onAddToBasket()
                            }
                        },
                        isInBasket: storage.isProductInBasket(productId: roll.id),
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
    struct Texts {}
    
    struct Size {
        static let sushiWidth: CGFloat = 96.0
    }
}
