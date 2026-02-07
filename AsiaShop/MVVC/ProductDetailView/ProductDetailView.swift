//
//  ProductDetailView.swift
//  AsiaShop
//
//  Created by Roman on 11/21/23.
//

import SwiftUI

struct ProductDetailView: View {
    
    @ObservedObject var viewModel: ProductDetailViewModel
    @State var count = 1
    
    var onDecrease: (() -> Void)? = nil
    var onIncrease: (() -> Void)? = nil
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Image(viewModel.product.imageURL)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipped()
                    
                    HStack {
                        Text(viewModel.product.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    Spacer()
                    
                    Text(viewModel.product.description)
                        .font(.subheadline)
                        .foregroundColor(Constants.Colors.blackOpacity70)
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                .padding(.bottom, 20)
            }
            
            HStack(spacing: 12) {
                makeQuantityButton
                AddToBasketButton(
                    price: viewModel.product.price,
                    count: count,
                    onTap: {
                        var position = Position(
                            id: UUID().uuidString,
                            product: viewModel.product,
                            count: count
                        )
                        position.product.price = viewModel.product.price
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
    
    private var makeQuantityButton: some View {
        HStack(spacing: 0) {
            Button {
                if count > 1 { count -= 1 }
                onDecrease?()
            } label: {
                Text("-")
                    .font(Constants.Font.buttonFont)
                    .foregroundColor(.black)
                    .padding(Constants.Padding.quantityButton)
            }
            
            Text("\(count)")
                .font(Constants.Font.buttonFont)
                .foregroundColor(.black)
                .frame(minWidth: 28)
                .padding(Constants.Padding.quantityCountButton)
            
            Button {
                if count < 10 { count += 1 }
                onIncrease?()
            } label: {
                Text("+")
                    .font(Constants.Font.buttonFont)
                    .foregroundColor(.black)
                    .padding(Constants.Padding.quantityButton)
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

// MARK: - Constants

private struct Constants {
    struct Images {}
    
    struct Colors {
        static let blackOpacity70 = Color.black.opacity(0.7)
        static let blackOpacity90 = Color.black.opacity(0.9)
    }
    
    struct Font {
        static let buttonFont = SwiftUI.Font.system(size: 16, weight: .bold)
    }
    
    struct Padding {
        static let basketButton = EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
        static let quantityButton = EdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 12)
        static let quantityCountButton = EdgeInsets(top: 16, leading: 4, bottom: 16, trailing: 4)
    }
}

// MARK: - Preview

#Preview {
    ProductDetailView(
        viewModel: ProductDetailViewModel(
            product: Product(
                id: "1",
                title: "Нори",
                imageURL: "nori",
                price: 17.5,
                description: "Японское название различных съедобных видов красных водорослей из рода Порфира."
            )
        )
    )
}
