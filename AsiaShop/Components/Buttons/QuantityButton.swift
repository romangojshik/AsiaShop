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
        .frame(width: 114, height: 35)
        .background(Color.black.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var quantityStepperView: some View {
        HStack(spacing: 0) {
            stepperButton(title: "-", action: onDecrease)
            
            Text("\(count)")
                .font(.buttonFont)
                .foregroundColor(.white)
                .frame(width: 38, height: 35)
            
            stepperButton(title: "+", action: onIncrease)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func stepperButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.buttonFont)
                .foregroundColor(.white)
                .frame(
                    width: Constants.Paddings.frameButton.width,
                    height: Constants.Paddings.frameButton.height
                )
        }
    }
    
    private var addToBasketButtonView: some View {
        Button(action: {
            onAddToBasket?()
        }) {
            Text(Constants.Texts.inBasket)
                .font(.buttonFont)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Constants

private struct Constants {
    struct Texts {
        static let inBasket = "В корзину"
    }
    
    struct Paddings {
        static let frameButton = CGSize(width: 38, height: 30)
    }
}
