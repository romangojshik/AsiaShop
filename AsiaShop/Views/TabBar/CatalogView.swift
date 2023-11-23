//
//  CatalogView.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

struct CatalogView: View {
    
    let layout = [GridItem(.adaptive(minimum: screen.width / 2.4))]
    
    enum Sections: String {
        case one = "Рекомендуем"
        case two = "Популярное"
        case three = "Основное меню"
        case four = "Header 4"
    }
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            Section(
                header: Text(Sections.one.rawValue)
                    .padding(),
                content: {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: layout, spacing: 16, content: {
                            ForEach(CatalogViewModel.shared.popularProducts, id: \.id) { item in
                                let viewModel = ProductDetailViewModel(product: item)
                                NavigationLink(
                                    destination: ProductDetailView(viewModel: viewModel),
                                    label: {
                                        ProductCell(product: item)
                                            .foregroundColor(Color.black)
                                    })
                            }
                        }).padding()
                    }
                })
            
            Section(
                header: Text(Sections.two.rawValue)
                    .padding(),
                content: {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: layout, spacing: 16, content: {
                            ForEach(CatalogViewModel.shared.popularProducts, id: \.id) { item in
                                let viewModel = ProductDetailViewModel(product: item)
                                NavigationLink(
                                    destination: ProductDetailView(viewModel: viewModel),
                                    label: {
                                        ProductCell(product: item)
                                            .foregroundColor(Color.black)
                                    })
                            }
                        }).padding()
                    }
                })
//
//            Section(
//                header: Text(Sections.three.rawValue)
//                .padding(),
//                content: {
//                    ScrollView(.vertical, showsIndicators: false) {
//                        LazyVGrid(columns: layout, spacing: 16, content: {
//                            ForEach(CatalogViewModel.shared.popularProducts, id: \.id) { item in
//                                ProductCell(product: item)
//                                    .foregroundColor(Color.black)
//                            }
//                        }).padding()
//                    }
//                })
        }
        .navigationBarTitle(Text("Каталог"))
    }
}

struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogView()
    }
}
