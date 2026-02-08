//
//  AddToBasketButton.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 07.02.26.
//

import SwiftUI

struct AddToBasketButton: View {
    let price: Double
    let count: Int
    let onTap: () -> Void
    
    private var totalPrice: Double {
        price * Double(count)
    }
    
    var body: some View {
        Button(action: onTap) {
            Text("\(Constants.Texts.add) \(String(format: "%.0f", totalPrice)) руб")
                .font(Constants.Fonts.buttonFont)
                .foregroundColor(.white)
                .padding(Constants.Padding.basketButton)
                .background(Constants.Colors.blackOpacity90)
                .cornerRadius(10)
        }
    }
}


private struct Constants {
    struct Texts {
        static let add = "Добавить"
    }
    
    struct Colors {
        static let blackOpacity90 = Color.black.opacity(0.9)
    }
    
    struct Fonts {
        static let buttonFont = SwiftUI.Font.system(size: 16, weight: .bold)
    }
    
    struct Padding {
        static let basketButton = EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
    }
}
