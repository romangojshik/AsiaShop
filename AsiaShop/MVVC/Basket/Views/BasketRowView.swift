//
//  BasketRowView.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import SwiftUI

struct BasketRowView: View {
    @EnvironmentObject var storage: OrderDataStorage
    
    // MARK: - Public properties
    
    public let positionID: String
    
    // MARK: - Private properties
    
    private var position: Position? {
        storage.positions.first { $0.id == positionID }
    }
    
    var body: some View {
        HStack(spacing: AppConstants.Padding.padding16) {
            URLImageView(urlString: position?.product.imageURL ?? "")
                .frame(
                    width: AppConstants.Size.productImage.width,
                    height: AppConstants.Size.productImage.height
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(position?.product.title ?? .empty)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(position?.product.composition ?? .empty)
                    .font(.subheadline)
                    .foregroundColor(AppConstants.Colors.blackOpacity90)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(String(format: "%.2f руб", position?.cost ?? 0.0))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppConstants.Colors.blackOpacity90)
                    
                    Spacer()
                    
                    QuantityButton(
                        count: position?.count ?? 0,
                        onDecrease: {
                            storage.decreaseCount(positionId: positionID)
                        },
                        onIncrease: {
                            storage.increaseCount(positionId: positionID)
                        }
                    )
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                storage.removePosition(positionId: positionID)
            } label: {
                Image(systemName: Constants.Images.trash)
                    .foregroundColor(AppConstants.Colors.blackOpacity90)
            }
        }
    }
}

// MARK: - Constants
private struct Constants {
    struct Images {
        static let trash = "trash"
    }
}
