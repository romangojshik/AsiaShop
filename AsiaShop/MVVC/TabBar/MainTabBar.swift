//
//  MainTabBar.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

enum Tab: Hashable {
    case catalog
    case basket
}

struct MainTabBar: View {
    
    var viewModel: MainTapBarViewModel
    
    @StateObject private var basketVM = BasketViewModel()
    @State private var selectedTab: Tab = .catalog
    
    init(viewModel: MainTapBarViewModel) {
        self.viewModel = viewModel
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(white: 0.15, alpha: 1.0)

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

        // Цвет НЕактивных элементов
        UITabBar.appearance().unselectedItemTintColor = .gray
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                CatalogView(basket: basketVM)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                VStack {
                    Image("catalog")
                        .renderingMode(.template)
                    Text("Каталог")
                }
            }
            .tag(Tab.catalog)
            
            BasketView(viewModel: basketVM)
                .tabItem {
                    VStack {
                        Image("basket")
                            .renderingMode(.template)
                        Text("Корзина")
                    }
                }
            .tag(Tab.basket)
        }
        .tint(.white)
    }
}
