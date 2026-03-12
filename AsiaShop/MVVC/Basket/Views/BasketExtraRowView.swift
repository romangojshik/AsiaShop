//
//  BasketExtraRowView.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 7.03.26.
//

import SwiftUI

// MARK: - BasketExtraRowView
struct BasketExtraRowView: View {
    @EnvironmentObject var storage: OrderDataStorage
    
    let extraButton: ExtraButton

    private var count: Int {
        storage.extraCount(extra: extraButton)
    }
    
    private var cost: Double {
        Double(count) * extraButton.price
    }
    
    var body: some View {
        HStack(spacing: AppConstants.Padding.padding16) {
            QuantityButton(
                count: count,
                onDecrease: { storage.decreaseAddOn(extra: extraButton) },
                onIncrease: { storage.increaseAddOn(extra: extraButton) },
                alwaysShowStepper: true
            )
            
            Text(extraButton.rawValue)
                .font(.subheadline)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
            
            Spacer()
            Text(String(format: "%.2f руб", cost))
                .font(.subheadline)
                .foregroundColor(extraButton == .chopsticks ? .gray : AppConstants.Colors.blackOpacity90)
            
        }
        .padding(.horizontal)
        .padding(.vertical, AppConstants.Padding.padding8)
    }
}
