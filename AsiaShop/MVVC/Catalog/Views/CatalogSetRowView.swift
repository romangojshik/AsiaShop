//
//  CatalogSetRowView.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import SwiftUI

struct CatalogSetRowView: View {
    @EnvironmentObject var storage: OrderDataStorage
    
    let rollSet: RollSet
    var onCardTap: (() -> Void)? = nil
    
    private var product: Product {
        rollSet.toProduct()
    }
    
    private var isInBasket: Bool {
        storage.isProductInBasket(productId: product.id)
    }
        
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Padding.padding6) {
            ZStack(alignment: .bottomTrailing) {
                URLImageView(urlString: rollSet.imageURL)
                    .frame(width: Constants.Size.setWidth, height: Constants.Size.setWidth)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.Padding.padding18, style: .continuous))
                    .onTapGesture {
                        onCardTap?()
                    }
                
                QuantityPlusButton(
                    count: storage.getProductCount(productId: product.id),
                    containerWidth: Constants.Size.setWidth - AppConstants.Padding.padding12,
                    onDecrease: {
                        if let position = storage.positions.first(where: { $0.product.id == product.id }) {
                            storage.decreaseOrRemove(positionId: position.id)
                        }
                    },
                    onIncrease: {
                        if let position = storage.positions.first(where: { $0.product.id == product.id }) {
                            storage.increaseCount(positionId: position.id)
                        } else {
                            let position = Position(
                                id: UUID().uuidString,
                                product: product,
                                count: 1
                            )
                            storage.addPosition(position: position)
                        }
                    },
                    onAddToBasket: {
                        let position = Position(
                            id: UUID().uuidString,
                            product: product,
                            count: 1
                        )
                        storage.addPosition(position: position)
                    }
                )
                .padding(.horizontal, AppConstants.Padding.padding6)
                .padding(.bottom, AppConstants.Padding.padding6)
            }
            .clipped()
            
            VStack(alignment: .leading, spacing: AppConstants.Padding.padding6) {
                Text(String.costForSyshi(product.price))
                    .font(.buttonFont)
                    .foregroundColor(AppConstants.Colors.blackOpacity90)
                
                Text(product.title)
                    .font(.productTitleMediumFont)
                    .foregroundColor(AppConstants.Colors.blackOpacity90)

                Text(String.quantityWithGrams(
                    quantity: product.nutrition?.quantity ?? .empty,
                    weight:product.nutrition?.weight ?? .empty
                ))
                    .font(.descriptionFont)
                    .foregroundColor(AppConstants.Colors.blackOpacity70)
                
            }
            .frame(maxWidth: Constants.Size.setWidth, alignment: .leading)
            .onTapGesture {
                onCardTap?()
            }
        }
    }
}

// MARK: - Constants

private struct Constants {
    struct Size {
        static let setWidth: CGFloat = 110.0
    }
}
