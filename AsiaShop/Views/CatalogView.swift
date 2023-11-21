//
//  CatalogView.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

struct CatalogView: View {
    
    let layout = [GridItem(.adaptive(minimum: screen.width / 2.2))]
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: layout, spacing: 16, content: {
                        ForEach(CatalogViewModel.shared.popularProducts, id: \.id) { item in
                            NavigationLink(
                                destination: ProductDetailView(product: item),
                                label: {
                                    ProductCell(product: item)
                                        .foregroundColor(Color.black)
                                })
                        }
                    }).padding()
                }
            }
        }.navigationTitle(Text("Каталог"))
        
    }
}

struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogView()
    }
}
