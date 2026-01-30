//
//  QuantityButton.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import SwiftUI

struct QuantityButton: View {
    let count: Int
    let onDecrease: () -> Void
    let onIncrease: () -> Void
    let isInBasket: Bool
    let onAddToBasket: (() -> Void)?
    
    init(
        count: Int,
        onDecrease: @escaping () -> Void,
        onIncrease: @escaping () -> Void,
        isInBasket: Bool = true,
        onAddToBasket: (() -> Void)? = nil
    ) {
        self.count = count
        self.onDecrease = onDecrease
        self.onIncrease = onIncrease
        self.isInBasket = isInBasket
        self.onAddToBasket = onAddToBasket
    }
    
    var body: some View {
        Group {
            if isInBasket && count > 0 {
                quantityStepperView
            } else {
                addToBasketButtonView
            }
        }
        .frame(width: 98, height: 28)
        .background(Color.black.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var quantityStepperView: some View {
        HStack(spacing: 0) {
            Button(action: onDecrease) {
                Text("-")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 26, height: 28)
            }
            
            Text("\(count)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 30, height: 28)
            
            Button(action: onIncrease) {
                Text("+")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 26, height: 28)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var addToBasketButtonView: some View {
        Button(action: {
            onAddToBasket?()
        }) {
            Text("В корзину")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 28)
        }
    }
}

struct QuantityStepper_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            QuantityButton(
                count: 0,
                onDecrease: {},
                onIncrease: {},
                isInBasket: false,
                onAddToBasket: { print("Add to basket") }
            )
            
            QuantityButton(
                count: 2,
                onDecrease: { print("Decrease") },
                onIncrease: { print("Increase") },
                isInBasket: true
            )
        }
        .padding()
    }
}
