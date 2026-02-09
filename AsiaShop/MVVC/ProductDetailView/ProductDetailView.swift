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
                    
                    Spacer()
                    
                    Text(viewModel.product.title)
                        .font(Constants.Fonts.titleFont)
                        .foregroundColor(Constants.Colors.blackOpacity90)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    Text(viewModel.product.description)
                        .font(.subheadline)
                        .foregroundColor(Constants.Colors.blackOpacity70)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    Text(Constants.Texts.composition)
                        .font(Constants.Fonts.titleDescriptionFont)
                        .foregroundColor(Constants.Colors.blackOpacity90)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    Text(viewModel.product.composition ?? "")
                        .font(Constants.Fonts.descriptionFont)
                        .foregroundColor(Constants.Colors.blackOpacity70)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    if viewModel.product.nutrition != nil {
                        ProductAttributesRow(product: viewModel.product)
                            .padding(.top, 16)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
            
            HStack(spacing: 12) {
                QuantityStepperButton(
                    count: $count,
                    onDecrease: onDecrease,
                    onIncrease: onIncrease
                )
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
}

// MARK: - Product attribute cells

private struct ProductAttributeCell: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Constants.Colors.blackOpacity90)
            Text(label)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Constants.Colors.blackOpacity70)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

private struct ProductAttributesRow: View {
    let product: Product
    
    var body: some View {
        guard let nutrition = product.nutrition else {
            return AnyView(EmptyView())
        }
        
        let items: [(String, String)] = [
            (nutrition.weight, "вес (г)"),
            (nutrition.callories, "ккал"),
            (nutrition.protein, "белки (г)"),
            (nutrition.fats, "жиры (г)")
        ].compactMap { value, label in
            guard let value = value, !value.isEmpty else { return nil }
            return (value, label)
        }
        
        if items.isEmpty {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            HStack(spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    ProductAttributeCell(value: item.0, label: item.1)
                }
            }
        )
    }
}

// MARK: - Constants

private struct Constants {
    struct Images {}
    
    struct Texts {
        static let composition = "Состав:"
    }
    
    struct Colors {
        static let blackOpacity70 = Color.black.opacity(0.7)
        static let blackOpacity90 = Color.black.opacity(0.9)
    }
    
    struct Fonts {
        static let titleFont = SwiftUI.Font.system(size: 18, weight: .bold)
        static let titleDescriptionFont = SwiftUI.Font.system(size: 14, weight: .semibold)
        static let descriptionFont = SwiftUI.Font.system(size: 14, weight: .regular)
        static let buttonFont = SwiftUI.Font.system(size: 16, weight: .bold)
    }
    
    struct Padding {}
}

// MARK: - Preview

#Preview {
    ProductDetailView(
        viewModel: ProductDetailViewModel(
            product: Product(
                id: "1",
                imageURL: "nori",
                title: "Нори",
                description: "Японское название различных съедобных видов красных водорослей из рода Порфира.",
                price: 17.5,
                composition: "Креветка темпура, сыр, огурец",
                nutrition: Nutrition(weight: "108", callories: "45", protein: "6", fats: "1")
            )
        )
    )
}
