//
//  SushiRowView.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import SwiftUI

struct SushiRowView: View {
    @ObservedObject var basketViewModel: BasketViewModel
    let sushi: Sushi
    let onAddToBasket: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(sushi.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(sushi.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(sushi.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(String(format: "%.0fруб/8шт", sushi.price))
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    Spacer()
                    
                    Button {
                        onAddToBasket()
                    } label: {
                        Text(basketViewModel.isProductInBasket(productId: sushi.id) ? "В корзине" : "В корзину")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(basketViewModel.isProductInBasket(productId: sushi.id) ? Color.green.opacity(0.9) : Color.black.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}
