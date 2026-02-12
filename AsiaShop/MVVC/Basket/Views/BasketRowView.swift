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
        HStack(spacing: 16) {
            Image(position?.product.imageURL ?? Constants.Images.placeholderSushi)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(position?.product.title ?? "")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(position?.product.description ?? "")
                    .font(.subheadline)
                    .foregroundColor(Constants.Colors.blackOpacity90)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(String(format: "%.2f руб", position?.cost ?? ""))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Constants.Colors.blackOpacity90)
                    
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
                    .foregroundColor(Constants.Colors.blackOpacity90)
            }
        }
    }
}

// MARK: - Constants
private struct Constants {
    struct Images {
        static let placeholderSushi = "placeholder_sushi"
        static let trash = "trash"
    }
    
    struct Colors {
        static let blackOpacity70 = Color.black.opacity(0.7)
        static let blackOpacity90 = Color.black.opacity(0.9)
        
    }
}
