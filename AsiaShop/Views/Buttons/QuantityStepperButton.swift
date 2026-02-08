//
//  QuantityStepperButton.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 08.02.26.
//

import SwiftUI

struct QuantityStepperButton: View {
    @Binding var count: Int
    var onDecrease: (() -> Void)? = nil
    var onIncrease: (() -> Void)? = nil
    
    private let minCount = 1
    private let maxCount = 10
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                if count > minCount { count -= 1 }
                onDecrease?()
            } label: {
                Text("-")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .padding(EdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 12))
            }
            
            Text("\(count)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .frame(minWidth: 28)
                .padding(EdgeInsets(top: 16, leading: 4, bottom: 16, trailing: 4))
            
            Button {
                if count < maxCount { count += 1 }
                onIncrease?()
            } label: {
                Text("+")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .padding(EdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 12))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}
