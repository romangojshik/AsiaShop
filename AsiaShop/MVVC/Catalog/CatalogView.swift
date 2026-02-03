//
//  CatalogView.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

struct CatalogView: View {
    
    @StateObject private var viewModel: CatalogViewModel
    @ObservedObject private var basket: BasketViewModel
    
    init(basket: BasketViewModel) {
        self.basket = basket
        _viewModel = StateObject(wrappedValue: CatalogViewModel(basket: basket))
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // Секция "Основное меню" - вертикальный список по одному продукту
    private var mainMenuSection: some View {
        Group {
            if !viewModel.sushi.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Основное меню")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.sushi.enumerated()), id: \.element.id) { index, sushi in
                            VStack(spacing: 0) {
                                NavigationLink(
                                    destination: ProductDetailView(
                                        viewModel: ProductDetailViewModel(product: sushi.toProduct())
                                    )
                                ) {
                                    SushiRowView(
                                        basketViewModel: basket,
                                        sushi: sushi,
                                        onAddToBasket: {
                                            viewModel.addToBasket(product: sushi.toProduct())
                                        }
                                    )
                                }
                                
                                if index < viewModel.sushi.count - 1 {
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
        VStack(spacing: 0) {
            CustomNavigationBarView(title: "Каталог")
            ScreenContainer {
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
                                                CatalogSetRowView(basket: basket, sushiSet: sushiSet)
                                                    .foregroundColor(.black)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        mainMenuSection
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if viewModel.sushi.isEmpty {
                viewModel.loadProducts()
            }
        }
    }
}
