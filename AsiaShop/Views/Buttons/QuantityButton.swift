//
//  QuantityStepper.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import SwiftUI

struct QuantityButton: View {
    let count: Int
    let onDecrease: () -> Void
    let onIncrease: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                onDecrease()
            } label: {
                Text("-")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }
            
            Text("\(count)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 44)
            
            Button {
                onIncrease()
            } label: {
                Text("+")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }
        }
//        .background(Color.gray.opacity(0.5))
        .background(Color.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct QuantityStepper_Previews: PreviewProvider {
    static var previews: some View {
        QuantityButton(
            count: 2,
            onDecrease: { print("Decrease") },
            onIncrease: { print("Increase") }
        )
        .padding()
    }
}
