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
    
    private let extra: Extra

    private var count: Int {
        storage.addOnCount(for: extra)
    }
    
    private var cost: Double {
        Double(count) * extra.price
    }
    
    init(extra: Extra) {
        self.extra = extra
    }
    
    var body: some View {
        HStack(spacing: AppConstants.Padding.padding16) {
            QuantityButton(
                count: count,
                onDecrease: { storage.decreaseAddOn(extra) },
                onIncrease: { storage.increaseAddOn(extra) },
                alwaysShowStepper: true
            )
            Text(extra.rawValue)
                .font(.subheadline)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
            Spacer()
            Text(String(format: "%.2f руб", cost))
                .font(.subheadline)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
        }
        .padding(.vertical, AppConstants.Padding.padding8)
    }
}
