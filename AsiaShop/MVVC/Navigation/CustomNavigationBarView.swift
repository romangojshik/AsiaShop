//
//  CustomNavigationBarView.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 30.01.26.
//

import SwiftUI

struct CustomNavigationBarView: View {
    let title: String
    var backgroundColor: Color = Color(white: 0.15)
    var textColor: Color = .white
    var fontSize: CGFloat = 30
    
    var body: some View {
        HStack {
            Spacer()
            
            Text(title)
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundColor(textColor)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(backgroundColor)
    }
}
