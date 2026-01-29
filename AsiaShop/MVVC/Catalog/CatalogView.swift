//
//  CatalogView.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

struct CatalogView: View {
    
    @StateObject private var viewModel = CatalogViewModel()
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // Секция "Основное меню" - вертикальный список по одному продукту
    private var mainMenuSection: some View {
        Group {
            if !viewModel.allProducts.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Основное меню")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.allProducts.enumerated()), id: \.element.id) { index, product in
                            VStack(spacing: 0) {
                                NavigationLink(
                                    destination: ProductDetailView(
                                        viewModel: ProductDetailViewModel(product: product)
                                    )
                                ) {
                                    HStack(spacing: 16) {
                                        Image(product.imageURL)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 96, height: 96)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(product.title)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text(product.description)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                            
                                            HStack {
                                                Text(String(format: "%.0fруб/8шт", product.price))
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(Color.black.opacity(0.9))
                                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                                
                                                Spacer()
                                                
                                                Button {
                                                    let position = Position(
                                                        id: UUID().uuidString,
                                                        product: product,
                                                        count: 1
                                                    )
                                                    BasketViewModel.shared.addPosition(position: position)
                                                } label: {
                                                    Text("В корзину")
                                                        .font(.subheadline)
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 4)
                                                        .background(Color.black.opacity(0.9))
                                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                                }
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                                
                                if index < viewModel.allProducts.count - 1 {
                                    Divider()
                                        .padding(16)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                // Секция "Готовые сеты" - горизонтальный скролл
                if !viewModel.sushiSets.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Готовые сеты")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.sushiSets, id: \.id) { sushiSet in
                                    NavigationLink(
                                        destination: ProductDetailView(
                                            viewModel: ProductDetailViewModel(product: sushiSet.toProduct())
                                        )
                                    ) {
                                        CatalogSetCell(sushiSet: sushiSet)
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Секция "Основное меню" - вертикальный список по одному продукту
                mainMenuSection
            }
            .padding(.vertical)
        }
        .navigationBarTitle("Каталог", displayMode: .large)
        .onAppear {
            if viewModel.allProducts.isEmpty {
                viewModel.loadProducts()
            }
        }
    }
}

struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CatalogView()
        }
    }
}
