//
//  WhiteOrBlackButton.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 11.02.26.
//

import SwiftUI

/// Универсальная кнопка с закруглёнными краями и настраиваемыми цветами.
struct WhiteOrBlackButton: View {
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void

    init(
        title: String,
        backgroundColor: Color = .black,
        foregroundColor: Color = .white,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .cornerRadius(12)
        }
    }
}

