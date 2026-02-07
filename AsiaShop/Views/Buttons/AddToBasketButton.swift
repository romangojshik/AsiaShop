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
            Text("В корзину \(String(format: "%.0f", totalPrice)) руб")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32))
                .background(Color.black.opacity(0.9))
                .cornerRadius(10)
        }
    }
}
