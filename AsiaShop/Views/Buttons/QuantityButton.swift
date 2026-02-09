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
        .frame(width: 114, height: 30)
        .background(Color.black.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var quantityStepperView: some View {
        HStack(spacing: 0) {
            Button(action: onDecrease) {
                Text("-")
                    .font(Constants.Fonts.buttonFont)
                    .foregroundColor(.white)
                    .frame(
                        width: Constants.Padding.frameButton.width,
                        height: Constants.Padding.frameButton.height
                    )
            }
            
            Text("\(count)")
                .font(Constants.Fonts.buttonFont)
                .foregroundColor(.white)
                .frame(width: 38, height: 30)
            
            Button(action: onIncrease) {
                Text("+")
                    .font(Constants.Fonts.buttonFont)
                    .foregroundColor(.white)
                    .frame(
                        width: Constants.Padding.frameButton.width,
                        height: Constants.Padding.frameButton.height
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var addToBasketButtonView: some View {
        Button(action: {
            onAddToBasket?()
        }) {
            Text(Constants.Texts.inBasket)
                .font(Constants.Fonts.buttonFont)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Constants

private struct Constants {
    struct Texts {
        static let inBasket = "В корзину"
    }
    
    struct Colors {
        static let blackOpacity90 = Color.black.opacity(0.9)
    }
    
    struct Fonts {
        static let buttonFont = SwiftUI.Font.system(size: 16, weight: .medium)
    }
    
    struct Padding {
        static let frameButton = CGSize(width: 38, height: 30)
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
