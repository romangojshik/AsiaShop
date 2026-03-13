//
//  CatalogView.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI


struct CatalogView: View {
    @EnvironmentObject var storage: OrderDataStorage
    
    var body: some View {
        CatalogContentView(
            viewModel: CatalogViewModel(
                database: YandexCatalogService.shared,
                storage: storage
            )
        )
    }
}

struct CatalogContentView: View {
    @StateObject var viewModel: CatalogViewModel
    
    @State private var selectedProduct: Product?
    
    private var shimmerContent: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                ShimmerRectangle(width: 140, height: 24, cornerRadius: 6)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<4, id: \.self) { _ in
                            CatalogSetRowShimmerView()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ShimmerRectangle(width: 140, height: 24, cornerRadius: 6)
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { index in
                        SushiRowShimmerView()
                        if index < 4 {
                            ShimmerRectangle(height: 1, cornerRadius: 0)
                                .padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
    }
    
    private var catalogContent: some View {
        Group {
            if !viewModel.sushiSets.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(Constants.Texts.readySets)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.sushiSets, id: \.id) { sushiSet in
                                CatalogSetRowView(
                                    sushiSet: sushiSet,
                                    onCardTap: { selectedProduct = sushiSet.toProduct() }
                                )
                                .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            mainMenuSection
        }
    }
    
    // Секция "Основное меню" - вертикальный список по одному продукту
    private var mainMenuSection: some View {
        Group {
            if !viewModel.sushi.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(Constants.Texts.mainMenu)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.sushi.enumerated()), id: \.element.id) { index, sushi in
                            VStack(spacing: 0) {
                                Button {
                                    selectedProduct = sushi.toProduct()
                                } label: {
                                    SushiRowView(
                                        sushi: sushi,
                                        onAddToBasket: {
                                            viewModel.addToBasket(product: sushi.toProduct())
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                                
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
            CustomNavigationBarView(title: Constants.Texts.catalog)
            ScreenContainer {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        if viewModel.isLoading {
                            shimmerContent
                        } else {
                            catalogContent
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedProduct) { product in
            Group {
                if #available(iOS 16.4, *) {
                    ProductDetailView(
                        viewModel: ProductDetailViewModel(product: product)
                    )
                    .presentationDetents([.fraction(0.82), .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Color.white)
                } else {
                    ProductDetailView(
                        viewModel: ProductDetailViewModel(product: product)
                    )
                }
            }
        }
        .onAppear {
            if viewModel.sushi.isEmpty {
                viewModel.loadProducts()
            }
        }
    }
}

// MARK: - Constants

private struct Constants {
    struct Texts {
        static let mainMenu = "Основное меню"
        static let catalog = "Каталог"
        static let readySets = "Готовые сеты"
    }
}
