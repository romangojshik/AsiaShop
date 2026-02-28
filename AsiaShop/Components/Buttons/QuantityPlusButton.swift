//
//  QuantityPlusButton.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 30.01.26.
//

import SwiftUI

public struct QuantityPlusButton: View {
    @State private var isExpanded: Bool = false
    
    let count: Int
    let containerWidth: CGFloat?
    let onDecrease: () -> Void
    let onIncrease: () -> Void
    let onAddToBasket: () -> Void
    
    init(
        count: Int,
        containerWidth: CGFloat? = nil,
        onDecrease: @escaping () -> Void,
        onIncrease: @escaping () -> Void,
        onAddToBasket: @escaping () -> Void
    ) {
        self.count = count
        self.containerWidth = containerWidth
        self.onDecrease = onDecrease
        self.onIncrease = onIncrease
        self.onAddToBasket = onAddToBasket
    }
    
    private var hasItems: Bool {
        count > 0
    }
    
    public var body: some View {
        Group {
            if hasItems {
                HStack(spacing: 0) {
                    Button {
                        onDecrease()
                    } label: {
                        Text(Constants.Texts.minus)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(
                                width: Constants.Paddings.qtyButtonSize,
                                height: Constants.Paddings.qtyButtonSize
                            )
                    }
                    
                    Text("\(count)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                    
                    Button {
                        onIncrease()
                    } label: {
                        Text(Constants.Texts.plus)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(
                                width: Constants.Paddings.qtyButtonSize,
                                height: Constants.Paddings.qtyButtonSize
                            )
                    }
                }
                .background(Color.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(width: containerWidth ?? 88, height: 28)
            } else {
                // Круглая кнопка с плюсом
                Button {
                    onAddToBasket()
                } label: {
                    Image(systemName: Constants.Images.plus)
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hasItems)
    }
}

// MARK: - Constants

private struct Constants {
    struct Images {
        static let plus = "plus"
    }
    
    struct Texts {
        static let plus = "+"
        static let minus = "-"
    }
    
    struct Colors {
        static let blackOpacity90 = Color.black.opacity(0.9)
    }
    
    struct Fonts {
        static let buttonFont = SwiftUI.Font.system(size: 16, weight: .bold)
    }
    
    struct Paddings {
        static let qtyButtonSize = CGFloat(30)
        
    }
}
