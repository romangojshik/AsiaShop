//
//  BasketRowView.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import SwiftUI

struct BasketRowView: View {
    // MARK: - Public properties
    
    @ObservedObject var basketViewModel: BasketViewModel
    public let positionID: String
    
    // MARK: - Private properties
    
    private var position: Position? {
        basketViewModel.positions.first { $0.id == positionID }
    }
    
    
    var body: some View {
        HStack(spacing: 16) {
            Image("placeholder_sushi_100")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(position?.product.title ?? "")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(position?.product.description ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(String(format: "%.2f руб", position?.cost ?? ""))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.black.opacity(0.9))
                    
                    Spacer()
                    
                    QuantityButton(
                        count: position?.count ?? 0,
                        onDecrease: {
                            basketViewModel.decreaseCount(positionId: positionID)
                        },
                        onIncrease: {
                            basketViewModel.increaseCount(positionId: positionID)
                        }
                    )
                }
            }
            
        }
    }
}
