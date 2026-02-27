//
//  CatalogSetRowView.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import SwiftUI

struct CatalogSetRowView: View {
    @EnvironmentObject var storage: OrderDataStorage
    let sushiSet: SushiSet
    var onCardTap: (() -> Void)? = nil
    
    private var product: Product {
        sushiSet.toProduct()
    }
    
    private var isInBasket: Bool {
        storage.isProductInBasket(productId: product.id)
    }
    
    private let cardWidth: CGFloat = 120
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: sushiSet.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.1)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Color.gray.opacity(0.1)
                    @unknown default:
                        Color.gray.opacity(0.1)
                    }
                }
                .frame(width: cardWidth, height: cardWidth)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .onTapGesture {
                    onCardTap?()
                }
                
                QuantityPlusButton(
                    count: storage.getProductCount(productId: product.id),
                    containerWidth: cardWidth - 12,
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
                            storage.addPosition(position)
                        }
                    },
                    onAddToBasket: {
                        let position = Position(
                            id: UUID().uuidString,
                            product: product,
                            count: 1
                        )
                        storage.addPosition(position)
                    }
                )
                .padding(.horizontal, 6)
                .padding(.bottom, 6)
            }
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                Text(String(format: "%.0fруб.", product.price))
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(2)
                
                HStack {
                    Text(product.nutrition?.weight ?? "")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Constants.Colors.blackOpacity70)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(product.nutrition?.callories ?? "")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Constants.Colors.blackOpacity70)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: cardWidth)
            .padding(.horizontal, 8)
            .padding(.bottom, 4)
            .contentShape(Rectangle())
            .onTapGesture {
                onCardTap?()
            }
        }
    }
}

// MARK: - Constantsprivate struct Constants {
private struct Constants {
    struct Colors {
        static let blackOpacity70 = Color.black.opacity(0.7)
    }
}
